# arcticcoind-docker
Arcticcoin (ARC) Daemon / Wallet Blockchain in Docker

This container uses the cryptocoin-base container (https://quay.io/repository/kwiksand/cryptocoin-base) which installs ubuntu and all the bitcoin build dependencies (miniupnp, berkelyDB 4.8, system build tools, etc)

## Usage

This repository contains the docker build if you'd like to manually build, but also points back at the quay.io docker build image (i.e `docker pull quay.io/kwiksand/arcticcoind:latest`).

To setup in the simplest way:
* Install docker-ce (any recent docker version) on your machine/VPS/Raspberry Pi
* Checkout git repository - `git clone https://github.com/kwiksand/arcticoind-docker.git`
* Make a directory for the wallet/blockchain/logs to sit/write to - `mkdir /media/crypto/arcticcoin`
* Edit docker-compose.yml, changing the volume line to the directory chosen above:
```bash
  volumes:
   - /media/crypto/arcticcoin:/home/arcticcoin/.arcticcoin
```
* Copy the example config, moving it to the directory chosen above:
```bash
  cp arcticcoin.conf.example /media/crypto/arcticcoin/arcticcoin.conf
```
* Edit the new config, changing the username and password (something long/random)
* Start via docker-compose - `docker-compose up -d`
* After a short while downloading the image and starting the container you should start to see the directory (/media/crypto/arcticcoin) fill with content
* Wait for the blockchain sync to complete - `tail -f /media/crypto/arcticcoin/debug.log`

By this stage you have a working arcticcoin wallet/blockchain setup, now we need to enable the masternode itself.  

# Masternode Setup

I'm planning on writing up a standard masternode set up guide for all DASH forked coins as the process is *almost* identical for the different coin types (at least the ones I've tried so far).

There are two methods for masternode setup:
* Cold Wallet with separate Masternode - Set up an additional ARC node separate to the wallet node (above) to act as the masternode.  The idea with this is the funds are stored in a separate, private location, and can be turned off after the masternode is started (i.e Cold)
* Hot Wallet (Single Node) - The node we've setup previously has masternode availability.

## Cold Wallet (Separate Master Node and Wallet Node)

* On a VPS, install Docker (a separate guide really), and re-follow the steps above
* ARC doesn't take long to sync, but you can copy the whole `/media/crypto/arcticcoin` directories between servers if you want to save time.  Just remove wallet.dat before re-starting the server
* *Wallet Node*: Generate a wallet address to receive funds, to fund/seed the masternode:
```bash
# arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf getaccountaddress mn1
AQ****************************HWZB
```
* TODO: Add separate guide to secure wallet
* Wait for 15 confirmations to the transactions:
```bash
# arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin
[
  {
    "account": "0",
    "address": "AQ****************************HWZB",
    "category": "receive",
    "amount": 1000.00000000,
    "label": "0",
    "vout": 0,
    "confirmations": 15,
    "bcconfirmations": 15,
    "blockhash": "00000000003a0c***************************************************4d0f",
    "blockindex": 1,
    "blocktime": 1504162949,
    "txid": "be***************************************************44",
    "walletconflicts": [
    ],
    "time": 1504162931,
    "timereceived": 1504162931,
    "bip125-replaceable": "no"
  },
  ```
* Generate a masternode private key:
```bash
# arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf goldminenode genkey
6u************************************************vp
```
* Get the masernode transaction information (based on the block transaction that fulfilled the masternode entry requirement of 1000 ARC coins
```bach
# arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf goldminenode outputs
{
  "be***************************************************44": "0"
}
```
### Save Node Information

Now we have all the information needed to start the masternode (or Gold Mine Node as it's called in the ARC world).

Most other guides recommend saving all information a file at this point to make sure it's all locked in and saved, so save the keys/ID's we've used above in a file:

```bash
Cold Wallet
-----------

Private Wallet Address: AQ****************************HWZB

Masternode
----------

VPS IP: 178.223.42.211
ARC Port: 7209
Private Key: 6u************************************************vp
Outputs:
 Code: be***************************************************44-0 made up of:
 Transaction ID: e***************************************************44
 Output Index: 0
Node Alias: mn1
```

### Start the Masternode

* *Wallet Node*: Update `/media/crypto/arcticcoin/goldminenode.conf` to tie the wallet to the masternode.  We need to add the details saved above by adding the line to the goldminenode.conf:
```bash
mn1 178.223.42.211:7209 6u************************************************vp be***************************************************44 0
```
* *Both Nodes*: Update `/media/crypto/arcticcoin/arcticcoin.conf` to add the masternode info, by adding the lines:
```bash
goldminenodenode=1
goldminenodeprivkey=6u************************************************vp
goldminenodeaddr=178.223.42.211:7209
```
* Restart Cold Wallet
* Restart Master node
* *Wallet Node*: Check masternode status
```bash
# arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf goldminenode list-conf
{
  "goldminenode": {
    "alias": "mn1",
    "address": "178.223.42.211:7209",
    "privateKey": "6u************************************************vp",
    "txHash": "be***************************************************44",
    "outputIndex": "0",
    "status": "PRE_ENABLED"
  }
}
````
* Note: The status will change from *PRE_ENABLED* to *ENABLED* after approximately half an hour.  If it's *ENABLED*
* Wait for payment :) (Check `# arcticcoin-cli -conf=/home/arcticcoin/.arcticcoin/arcticcoin.conf listtransactions` after a few days)

## TODO: Troubleshooting guide

# References:

There's loads of guides available online, and most are very similar, here's a few:
* https://steemit.com/arcticcoin/@grandola/how-to-setup-coldwallet-masternodes-with-arcticcoin-mac-linux-version
* https://steemit.com/arcticcoin/@bapparabi/arcticcoin-master-node-setup-earn-passive-income
