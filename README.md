Merchant
========================

A command line app that manages payments payments using the DirectLink API using Ogone payment services.

## Installation
Clone repository: `$ git clone git@github.com:dxw/merchant.git`

## Usage

Store details: ```$ ./merchant.rb -method="store" -params='reference' -fn='Bob' -ln='Benson' -cn='4242424242424242' -ct='visa' -m='8' -y='2015' -v='000' -a=1000 -pspid="PSPID" -user="USERNAME" -pass="PASSWORD"```

Make a payment: ```$ ./merchant.rb -method="purchase" -fn='Bob' -ln='Benson' -cn='4242424242424242' -ct='visa' -m='8' -y='2015' -v='000' -a=1000 -pspid="PSPID" -user="USERNAME" -pass="PASSWORD"```

