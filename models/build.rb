require 'digest/sha1'

class Build
  attr_reader :type, :source, :filename

  def initialize(type, source, filename = nil)
    @type = type
    @source = source
    @filename = filename
  end

  def hash
    Digest::SHA1.hexdigest("/* #{filename} - #{type} */\n\n#{source}")
  end

  def exists?
    $redis.sismember "builds", hash
  end

  def store!
    return false if exists?

    output = Util.compile!(type, source)
    compressed_output = Util.compress!(output)

    AWS::S3::S3Object.store(path + '.css', output, ENV["S3_BUCKET"], access: :public_read)
    AWS::S3::S3Object.store(path + '.min.css', compressed_output, ENV["S3_BUCKET"], access: :public_read)
    $redis.sadd "builds", hash
    true
  end

  def path
    ['builds', hash, filename].compact.join("/")
  end

  def url
    "//#{ENV['ASSET_HOST']}/#{path}.css"
  end

  def compressed_url
    "//#{ENV['ASSET_HOST']}/#{path}.min.css"
  end

  def serializable_hash
    {
      hash: hash,
      url: url,
      compressed_url: compressed_url
    }
  end
end