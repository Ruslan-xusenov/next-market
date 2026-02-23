from django.shortcuts import redirect
from django.urls import reverse

class ProfileCompletionMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        if request.user.is_authenticated and not request.user.is_staff:
            # Check if current path is allowed
            complete_profile_url = reverse('market:complete_profile')
            logout_url = reverse('account_logout')
            
            if request.path != complete_profile_url and request.path != logout_url and not request.path.startswith('/accounts/logout/'):
                user = request.user
                profile = getattr(user, 'profile', None)
                
                # Relaxed rule: Only enforce completion for checkout and sensitive parts
                protected_paths = [
                     reverse('market:checkout'),
                     '/checkout',
                     '/order',
                ]
                
                is_protected = False
                for path in protected_paths:
                    if request.path.startswith(path):
                        is_protected = True
                        break
                
                # Check for required fields: first_name, last_name, phone_number, address
                is_complete = (
                    user.first_name and 
                    user.last_name and 
                    profile and 
                    profile.phone_number and 
                    profile.address
                )
                
                if is_protected and not is_complete:
                    return redirect('market:complete_profile')
        
        response = self.get_response(request)
        return response

import uuid

class GuestUUIDMiddleware:
    def __init__(self, get_response):
        self.get_response = get_response

    def __call__(self, request):
        guest_uuid = request.COOKIES.get('guest_uuid')
        if not guest_uuid:
            guest_uuid = str(uuid.uuid4())
            request.guest_uuid = guest_uuid
        else:
            request.guest_uuid = guest_uuid
            
        response = self.get_response(request)
        
        # Set cookie if it was just generated
        # Set cookie if it was just generated
        if not request.COOKIES.get('guest_uuid'):
            response.set_cookie('guest_uuid', guest_uuid, max_age=365*24*60*60) # 1 year
            
        return response

