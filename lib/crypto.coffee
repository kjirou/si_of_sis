cryptoModule = require 'crypto'

conf = require 'conf'


crypto =
  # Ref) https://github.com/kjirou/nodejs_codes/blob/master/basis/crypto/auth_by_hmac_sha256_with_salt/index.js
  generateHashedPassword: (rawPassword, salt) ->
    sha = cryptoModule.createHmac 'sha256', conf.auth.hmacSecretKey
    sha.update rawPassword + salt
    return sha.digest 'hex'


module.exports = crypto
