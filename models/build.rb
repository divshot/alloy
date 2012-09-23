require 'digest/sha1'

class Build
  attr_reader :type, :source

  def initialize(type, source)
    @type = type
    @source = source
  end

  def hash
    Digest::SHA1.hexdigest("/* #{type} */\n\n#{source}")
  end

  def exists?
    $redis.sismember "builds", hash
  end

  def store!
    return false if exists?

    output = Util.compile!(type, source)
    compressed_output = Util.compile!(type, source, compress: true)

    AWS::S3::S3Object.store('builds/' + hash + '.css', output, ENV["S3_BUCKET"], access: :public_read)
    AWS::S3::S3Object.store('builds/' + hash + '.min.css', compressed_output, ENV["S3_BUCKET"], access: :public_read)
    $redis.sadd "builds", hash
    true
  end

  def url
    "//#{ENV['ASSET_HOST']}/builds/#{hash}.css"
  end

  def compressed_url
    "//#{ENV['ASSET_HOST']}/builds/#{hash}.min.css"
  end

  def serializable_hash
    {
      hash: hash,
      url: url,
      compressed_url: compressed_url
    }
  end
end