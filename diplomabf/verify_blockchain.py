import os
import django
from dotenv import load_dotenv

# Load .env
load_dotenv()

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'diplomabf.settings')
django.setup()

from diplomas.blockchain_utils import get_algod_client, get_treasury_account

def verify_blockchain_status():
    print("--- VERIFICATION BLOCKCHAIN ---")
    client = get_algod_client()
    
    try:
        status = client.status()
        print(f"✅ Connexion AlgoNode : OK")
        print(f"📦 Dernier Bloc : {status['last-round']}")
        
        pk, addr, _ = get_treasury_account()
        if addr:
            print(f"💰 Trésorerie : {addr}")
            # Get balance
            account_info = client.account_info(addr)
            balance = account_info.get('amount', 0) / 1_000_000
            print(f"💵 Solde Trésorerie : {balance} ALGO")
            
            if balance < 2:
                print("⚠️ ATTENTION : Solde insuffisant pour financer une université (min 2 ALGO).")
                print("👉 Allez sur : https://bank.testnet.algorand.network/")
        else:
            print("❌ Trésorerie non configurée dans le fichier .env")
            
    except Exception as e:
        print(f"❌ Erreur de connexion : {e}")

if __name__ == "__main__":
    verify_blockchain_status()
