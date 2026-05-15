from algosdk import account, mnemonic, transaction
from algosdk.v2client import algod
import os
import uuid

# Configuration loaded from environment variables
ALGOD_ADDRESS = os.getenv("ALGOD_URL", "https://testnet-api.algonode.cloud")
ALGOD_TOKEN = os.getenv("ALGOD_TOKEN", "")

def get_algod_client():
    return algod.AlgodClient(ALGOD_TOKEN, ALGOD_ADDRESS)

def get_treasury_account():
    """Retrieves the treasury account from environment variables."""
    treso_mnemonic = os.getenv("TRESO_MNEMONIC")
    if not treso_mnemonic:
        return None, None, None
    
    try:
        private_key = mnemonic.to_private_key(treso_mnemonic)
        address = account.address_from_private_key(private_key)
        return private_key, address, treso_mnemonic
    except Exception:
        return None, None, None

def get_balance(address):
    """Returns the balance of an account in ALGO."""
    client = get_algod_client()
    try:
        account_info = client.account_info(address)
        return account_info.get('amount', 0) / 1_000_000
    except Exception:
        return 0

def onboard_university(uni_name):
    """
    1. Generates a new account for the university.
    2. Funds it with 2 ALGO from the Treasury.
    """
    client = get_algod_client()
    
    # 1. Generate University Account
    uni_private_key, uni_address = account.generate_account()
    uni_mnemonic = mnemonic.from_private_key(uni_private_key)
    
    # 2. Fund the account from Treasury
    treso_private_key, treso_address, _ = get_treasury_account()
    
    if treso_private_key and treso_address:
        try:
            params = client.suggested_params()
            funding_txn = transaction.PaymentTxn(
                sender=treso_address,
                sp=params,
                receiver=uni_address,
                amt=2000000 # 2 ALGO
            )
            
            signed_funding = funding_txn.sign(treso_private_key)
            txid = client.send_transaction(signed_funding)
            print(f"University {uni_name} funded. TxID: {txid}")
        except Exception as e:
            print(f"Funding Error: {e}")
    else:
        print("Treasury not configured or mnemonic invalid.")

    return uni_address, uni_private_key, uni_mnemonic

def anchor_hash_on_algorand(document_hash, university_private_key):
    """
    Anchors a SHA-256 document hash using the university's own key.
    """
    client = get_algod_client()
    try:
        params = client.suggested_params()
        sender_address = account.address_from_private_key(university_private_key)
        
        note = f"MIAB_CERT:{document_hash}".encode()
        
        txn = transaction.PaymentTxn(sender_address, params, sender_address, 0, note=note)
        signed_txn = txn.sign(university_private_key)
        
        txid = client.send_transaction(signed_txn)
        return txid
    except Exception as e:
        print(f"Blockchain Anchoring Error: {e}")
        return None

def fund_account(receiver_address, amount_algo):
    """
    Funds a specific address with a certain amount of ALGO from the Treasury.
    amount_algo is in ALGO (will be converted to microAlgos).
    """
    client = get_algod_client()
    treso_private_key, treso_address, _ = get_treasury_account()
    
    if treso_private_key and treso_address:
        try:
            params = client.suggested_params()
            funding_txn = transaction.PaymentTxn(
                sender=treso_address,
                sp=params,
                receiver=receiver_address,
                amt=int(amount_algo * 1_000_000) # Convert to microAlgos
            )
            
            signed_funding = funding_txn.sign(treso_private_key)
            txid = client.send_transaction(signed_funding)
            print(f"Account {receiver_address} funded with {amount_algo} ALGO. TxID: {txid}")
            return txid
        except Exception as e:
            print(f"Funding Error: {e}")
            return None
    return None
