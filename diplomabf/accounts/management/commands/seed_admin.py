from django.core.management.base import BaseCommand
from accounts.models import CustomUser
import os

class Command(BaseCommand):
    help = 'Seeds an initial administrator user if none exists.'

    def handle(self, *args, **options):
        username = os.getenv('ADMIN_USERNAME', 'admin_diplo')
        email = os.getenv('ADMIN_EMAIL', 'admin@diplo-chain.bf')
        password = os.getenv('ADMIN_PASSWORD', 'AdminPassword123!')

        if not CustomUser.objects.filter(role='admin').exists():
            self.stdout.write('Creating initial administrator...')
            CustomUser.objects.create_user(
                username=username,
                email=email,
                password=password,
                first_name='Admin',
                last_name='System',
                role='admin'
            )
            self.stdout.write(self.style.SUCCESS(f'Successfully created admin: {username}'))
        else:
            self.stdout.write(self.style.WARNING('An administrator already exists. Skipping seeding.'))
