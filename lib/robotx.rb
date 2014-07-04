require 'timeout'
require 'stringio'
require 'open-uri'
require 'uri'
require 'set'

class Robotx

  TIMEOUT = 30 # seconds

  def initialize(uri, user_agent='*')
    @uri = URI.parse(URI.encode(uri))
    raise URI::InvalidURIError.new('scheme or host missing') unless @uri.scheme and @uri.host

    @user_agent  = user_agent.downcase
    @robots_data = parse_robots_txt
  end

  def allowed
    return disallowed.empty? ? ['/'] : @robots_data.fetch(@user_agent, {}).fetch('allow', ['/'])
  end

  def disallowed
    return @robots_data.fetch(@user_agent, {}).fetch('disallow', [])
  end

  def allowed?(data)
    if data.is_a?(Array) or data.is_a?(Set)
      return {}.tap do |hash|
        data.each do |uri|
          hash[uri] = check_permission(uri)
        end
      end
    end

    return check_permission(data)
  end

  def sitemap
    return @robots_data.fetch('sitemap', [])
  end

  def crawl_delay
    return [@robots_data.fetch(@user_agent, {}).fetch('crawl-delay', 0), 0].max
  end

  def user_agents
    return @robots_data.keys.delete_if { |agent| agent == 'sitemap' }
  end

private

  def load_robots_txt
    Timeout::timeout(Robotx::TIMEOUT) do
      if robots_txt_io = URI.join(@uri, 'robots.txt').open('User-Agent' => @user_agent) and robots_txt_io.content_type.downcase == 'text/plain' and robots_txt_io.status == ['200', 'OK']
        return robots_txt_io
      end
      raise OpenURI::HTTPError
    end
  rescue
    return StringIO.new("User-agent: *\nAllow: /\n")
  end

  def parse_robots_txt
    agent  = '*'
    {}.tap do |hash|
      load_robots_txt.each do |line|
        next if line =~ /^\s*(#.*|$)/

        data  = line.split(/:/).map(&:strip)
        key   = data.shift
        value = data.join

        case key.downcase
        when 'user-agent'
          agent = value.downcase
          hash[agent] ||= {}
        when 'allow'
          hash[agent]['allow'] ||= []
          hash[agent]['allow'] << value.sub(/(\/){2,}$/, '')
        when 'disallow'
          # Disallow: '' means Allow: '/'
          if value.empty?
            hash[agent]['allow'] ||= []
            hash[agent]['allow'] << '/'
          else
            hash[agent]['disallow'] ||= []
            hash[agent]['disallow'] << value.sub(/(\/){2,}$/, '')
          end
        when 'crawl-delay'
          hash[agent]['crawl-delay'] = value.to_i
        when 'sitemap'
          hash['sitemap'] ||= []
          hash['sitemap'] << value.sub(/(\/){2,}$/, '')
        else
          hash[key] ||= []
          hash[key] << value.sub(/(\/){2,}$/, '')
        end
      end
    end
  rescue
    {}
  end

  def check_permission(uri)
    uri = URI.parse(URI.encode(uri))
    return true unless (@robots_data or @robots_data.any?) or (uri.scheme and uri.host)

    uri_path = uri.path.sub(/(\/){2,}$/, '')
    pattern  = Regexp.compile("(^#{Regexp.escape(uri_path)}[\/]*$)|(^/$)")
    return (@robots_data.fetch(@user_agent, {}).fetch('disallow', []).grep(pattern).empty? or @robots_data.fetch(@user_agent, {}).fetch('allow', []).grep(pattern).any?)
  end

end
