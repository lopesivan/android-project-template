firstname    = $(shell shyaml get-value user.firstname < init.yaml )
lastname     = $(shell shyaml get-value user.lastname < init.yaml )
organization = $(shell shyaml get-value user.organization < init.yaml )
keystore     = $(shell shyaml get-value user.keystore < init.yaml )
   alias     = $(shell shyaml get-value user.alias < init.yaml )
validity     = $(shell shyaml get-value user.validity < init.yaml )

# KEYPASS   = $(shell cat pass1.txt)
# STOREPASS = $(shell cat pass2.txt)
# KEYPASS   = 9Ra1OO1O2uzhV6f8pv1xbM
# STOREPASS = qVg2Jm80h2XwFO8OJ2NvD8
KEYPASS   = "android"
STOREPASS = "android"
CN        = "CN=$(firstname) $(lastname), OU=$(organization), O=$(organization), L=Rio de Janeiro, ST=Rio de Janeiro, C=RJ"

build:
	make key
	./build.sh $@
yaml:
	./build.sh $@

init: init.yaml
	./build.sh $@

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
	sleep 2
	./key3.expect $(KEYPASS) $(STOREPASS)
	sleep 2
	openssl base64 -in $(keystore) -out key.txt

keystore:
	keytool \
		-J-Duser.language=en    \
		-genkey -noprompt       \
		-alias $(alias)         \
		-dname $(CN)            \
		-keystore $(keystore)   \
		-storepass $(STOREPASS) \
		-keypass $(KEYPASS)
	sleep 2
	./key3.expect $(STOREPASS) $(KEYPASS)

clean:
	# rm $(keystore)
	rm debug.*
