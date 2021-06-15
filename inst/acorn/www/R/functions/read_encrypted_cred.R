read_encrypted_cred <- function(rds, pwd) {
  tmp <- readRDS(rds)
  key_user <- sha256(charToRaw(pwd))
  unserialize(aes_cbc_decrypt(tmp, key = key_user))
}