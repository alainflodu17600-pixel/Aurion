using System;
using System.Security.Cryptography;
using System.Text;

namespace Aurion.Security
{
    public static class CryptoHelper
    {
        // Méthode d'exemple: chiffrement AES symétrique simple (pour prototype local uniquement)
        public static (string iv, string cipher) Encrypt(string plainText, byte[] key)
        {
            using var aes = Aes.Create();
            aes.Key = key;
            aes.GenerateIV();
            using var encryptor = aes.CreateEncryptor();
            var plainBytes = Encoding.UTF8.GetBytes(plainText);
            var cipherBytes = encryptor.TransformFinalBlock(plainBytes, 0, plainBytes.Length);
            return (Convert.ToBase64String(aes.IV), Convert.ToBase64String(cipherBytes));
        }

        public static string Decrypt(string ivBase64, string cipherBase64, byte[] key)
        {
            using var aes = Aes.Create();
            aes.Key = key;
            aes.IV = Convert.FromBase64String(ivBase64);
            using var decryptor = aes.CreateDecryptor();
            var cipherBytes = Convert.FromBase64String(cipherBase64);
            var plainBytes = decryptor.TransformFinalBlock(cipherBytes, 0, cipherBytes.Length);
            return Encoding.UTF8.GetString(plainBytes);
        }

        public static byte[] GenerateRandomKey(int size = 32) => RandomNumberGenerator.GetBytes(size);
    }
}
