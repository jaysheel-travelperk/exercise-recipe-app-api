"""
URL mappings for the user API.
"""
from django.urls import path

from user import views

app_name = 'user'

urlpatterns = [
    # 1st param --> create in URLs
    # 2nd param --> CreateUserView class in the Views python file
    # 3rd param --> name create this helps in the reverse in test_user_api
    path('create/', views.CreateUserView.as_view(), name='create'),
    path('token/', views.CreateTokenView.as_view(), name='token'),
    path('me/', views.ManageUserView.as_view(), name='me'),
]
