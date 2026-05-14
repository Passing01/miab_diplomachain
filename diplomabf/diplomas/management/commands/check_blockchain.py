from django.core.management.base import BaseCommand
from diplomas.blockchain_utils import get_algod_client, get_treasury_account

class Command(BaseCommand):
    help = 'Check connection to Algorand and treasury balance'

    def handle(self, *args, **options):
        self.stdout.write(self.style.SUCCESS("--- VERIFICATION BLOCKCHAIN ---"))
        client = get_algod_client()
        
        try:
            status = client.status()
            self.stdout.write(self.style.SUCCESS(f"✅ Connexion AlgoNode : OK"))
            self.stdout.write(f"📦 Dernier Bloc : {status['last-round']}")
            
            pk, addr, _ = get_treasury_account()
            if addr:
                self.stdout.write(f"💰 Trésorerie : {addr}")
                # Get balance
                account_info = client.account_info(addr)
                balance = account_info.get('amount', 0) / 1_000_000
                self.stdout.write(f"💵 Solde Trésorerie : {balance} ALGO")
                
                if balance < 2:
                    self.stdout.write(self.style.WARNING("⚠️ ATTENTION : Solde insuffisant pour financer une université (min 2 ALGO)."))
                    self.stdout.write("👉 Allez sur : https://bank.testnet.algorand.network/")
            else:
                self.stdout.write(self.style.ERROR("❌ Trésorerie non configurée (ALGORAND_TREASURY_ADDRESS manquante)"))
                
        except Exception as e:
            self.stdout.write(self.style.ERROR(f"❌ Erreur de connexion : {e}"))
