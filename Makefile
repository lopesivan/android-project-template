firstname    = ivan
lastname     = lopes
organization = 42algoritmos
keystore     = debug.keystore
   alias     = ivanlopes.eng.br
validity     = 10000

# KEYPASS   = $(shell cat pass1.txt)
# STOREPASS = $(shell cat pass2.txt)
# KEYPASS   = 9Ra1OO1O2uzhV6f8pv1xbM
# STOREPASS = qVg2Jm80h2XwFO8OJ2NvD8
KEYPASS   = _______senha1_______
STOREPASS = _______senha2_______

CN        = "CN=ivan lopes, OU=ivanlopes4242, O=ivanlopes4242, L=Rio de Janeiro, ST=Rio de Janeiro, C=RJ"

key1:
	keytool \
		-J-Duser.language=en  \
		-genkey -v            \
		-keystore $(keystore) \
		-alias $(alias)       \
		-keyalg RSA           \
		-keysize 2048         \
		-validity $(validity)

key2:
	keytool \
		-J-Duser.language=en      \
		-importkeystore           \
		-srckeystore $(keystore)  \
		-destkeystore $(keystore) \
		-deststoretype pkcs12

key:
	./key1.expect $(KEYPASS) $(firstname) $(lastname) $(organization) $(STOREPASS)
	./key3.expect $(KEYPASS) $(STOREPASS)
	# ./key2.expect $(KEYPASS) $(STOREPASS)

keystore:
	keytool \
		-J-Duser.language=en    \
		-genkey -noprompt       \
		-alias $(alias)         \
		-dname $(CN)            \
		-keystore $(keystore)   \
		-storepass $(STOREPASS) \
		-keypass $(KEYPASS)
	./key3.expect $(STOREPASS) $(KEYPASS)

clean:
	# rm $(keystore)
	rm debug.*
