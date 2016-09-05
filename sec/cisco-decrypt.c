/* Decoder for password encoding of Cisco VPN client.
   Copyright (C) 2005 Maurice Massar
   Thanks to HAL-9000@evilscientists.de for decoding and posting the algorithm!

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
*/

/*
   Requires libgcrypt version 1.1.90 or newer
   Compile with:
    gcc -Wall -o cisco-decrypt cisco-decrypt.c $(libgcrypt-config --libs --cflags)
   Usage:
    ./cisco-decrypt DEADBEEF...012345678 424242...7261
 */

#include <stdio.h>
#include <stdlib.h>
#include <gcrypt.h>
#include <errno.h>

int hex2bin_c(unsigned int c)
{
	if ((c >= '0')&&(c <= '9'))
		return c - '0';
	if ((c >= 'A')&&(c <= 'F'))
		return c - 'A' + 10;
	if ((c >= 'a')&&(c <= 'f'))
		return c - 'a' + 10;
	return -1;
}

int hex2bin(const char *str, char **bin, int *len)
{
	char *p;
	int i, l;
	
	if (!bin)
		return EINVAL;
	
	for (i = 0; str[i] != '\0'; i++)
		if (hex2bin_c(str[i]) == -1)
			return EINVAL;
	
	l = i;
	if ((l & 1) != 0)
		return EINVAL;
	l /= 2;
	
	p = malloc(l);
	if (p == NULL)
		return ENOMEM;
	
	for (i = 0; i < l; i++)
		p[i] = hex2bin_c(str[i*2]) << 4 | hex2bin_c(str[i*2+1]);
	
	*bin = p;
	if (len)
		*len = l;
	
	return 0;
}

int c_decrypt(char *ct, int len, char **resp, char *reslenp)
{
	const char *h1  = ct;
	const char *h4  = ct + 20;
	const char *enc = ct + 40;
	
	char ht[20], h2[20], h3[20], key[24];
	const char *iv = h1;
	char *res;
	gcry_cipher_hd_t ctx;
	int reslen;
	
	if (len < 48)
		return 0;
	len -= 40;
	
	memcpy(ht, h1, 20);
	
	ht[19]++;
	gcry_md_hash_buffer(GCRY_MD_SHA1, h2, ht, 20);
	
	ht[19] += 2;
	gcry_md_hash_buffer(GCRY_MD_SHA1, h3, ht, 20);
	
	memcpy(key, h2, 20);
	memcpy(key+20, h3, 4);
	/* who cares about parity anyway? */
	
	gcry_md_hash_buffer(GCRY_MD_SHA1, ht, enc, len);
	
	if (memcmp(h4, ht, 20) != 0)
		return -1;
	
	res = malloc(len);
	if (res == NULL)
		return -1;
	
	gcry_cipher_open(&ctx, GCRY_CIPHER_3DES, GCRY_CIPHER_MODE_CBC, 0);
	gcry_cipher_setkey(ctx, key, 24);
	gcry_cipher_setiv(ctx, iv, 8);
	gcry_cipher_decrypt(ctx, (unsigned char *)res, len, (unsigned char *)enc, len);
	gcry_cipher_close(ctx);
	
	reslen = len - res[len-1];
	res[reslen] = '\0';
	
	if (resp)
		*resp = res;
	if (reslenp)
		*reslenp = reslen;
	return 0;
}

int main(int argc, char *argv[])
{
	int i, len, ret = 0;
	char *bin, *pw;
	
	gcry_check_version(NULL);
	
	for (i = 1; i < argc; i++) {
		ret = hex2bin(argv[i], &bin, &len);
		if (ret != 0) {
			perror("decoding input");
			continue;
		}
		ret = c_decrypt(bin, len, &pw, NULL);
		free(bin);
		if (ret != 0) {
			perror("decrypting input");
			continue;
		}
		printf("%s\n", pw);
		free(pw);
	}
	
	exit(ret != 0);
}
