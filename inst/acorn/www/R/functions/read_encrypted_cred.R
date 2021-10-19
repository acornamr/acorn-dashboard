read_encrypted_cred <- function(rds, pwd) {
  tmp <- readRDS(rds)
  key_user <- openssl::sha256(charToRaw(pwd))
  unserialize(openssl::aes_cbc_decrypt(tmp, key = key_user))
}