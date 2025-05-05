"""
URL configuration for admin project.

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/5.0/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.contrib import admin
from django.urls import path

from django.conf import settings
from django.conf.urls.static import static


from app1 import views
from patient import views as v2
from physio import views as v3
from appointment import views as v4
from ratings_feedback import views as v5

urlpatterns = [
    path('',views.index),
    path('admin/', admin.site.urls),
    path('index/',views.index),
    path('login/',views.login),
    path('dashboard/',views.dashboard),
    path('managePatient/',v2.managePatient),
    path('managePhysiotherapist/',v3.managePhysiotherapist),
    path('manageProfile/',views.manageProfile),
    path('addPatient/',v2.addPatient),
    path('addPhysiotherapist/',v3.addPhysiotherapist),
    path('editAdmin/',views.editAdmin),
    path('editPatient/',v2.editPatient),
    path('editPhysiotherapist/',v3.editPhysiotherapist),
    path('error/',views.error),
    path('authUser/',views.authUser),
    path('patient/',v2.patient),
    path('physiotherapist/',v3.physiotherapist),
    path('deletePatient/<int:id>',v2.deletePatient,name='deletePatient'),
    path('deletePhysio/<int:id>',v3.deletePhysio,name='deletePhysio'),
    path("editPatient/<int:id>", v2.editPatient,name='editPatient'),
    path("editPhysio/<int:id>", v3.editPhysio,name='editPhysio'),
    path("editAdmin/<int:id>", views.editAdmin,name='editAdmin'),
    path("aboutus/",views.aboutus),
    path('appointment/',v4.appointment),
    path('addAppointment/',v4.addAppointment),
    path('manageAppointment/',v4.manageAppointment),
    path('deleteAppointment/<int:id>',v4.deleteAppointment,name="deleteAppointment"),
    path('editAppointment/<int:id>',v4.editAppointment,name="editAppointment"),
    path('ratings_feedback/',v5.ratings_feedback),



] 

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
