from django.shortcuts import render, get_object_or_404, redirect

from django.contrib import messages

# Create your views here.

from .models import Admin
from patient.models import Patient
from physio.models import Physiotherapist

def index(req):
	return render(req,"index.html")

def login(req):
	return render(req,"login.html")

def authUser(req):
    # Get data from the form
    username = req.POST.get("username")
    password = req.POST.get("password")
    email = req.POST.get("email")

    try:
        # Attempt to get the admin based on the provided username and email
        admin = Admin.objects.get(username=username, email=email)

        # Check if the password matches
        if admin.password == password:
            return redirect("/dashboard")  # Redirect to the dashboard if credentials are correct
        else:
            # If password doesn't match, show error
            messages.error(req, "Incorrect password.")
            return render(req, "error.html")
    
    except Admin.DoesNotExist:
        # If no admin matches the provided username and email, show error
        messages.error(req, "Admin with this username and email does not exist.")
        return render(req, "error.html")
    
    # If no data is submitted yet, return to the login page
    return render(req, "login.html")

def dashboard(request):
    no_of_patient = Patient.objects.count()
    no_of_physio = Physiotherapist.objects.count()
    return render(request, 'dashboard.html', {
        'no_of_patient': no_of_patient,
        'no_of_physio': no_of_physio
    })


def manageProfile(req):
	data=Admin.objects.all()
	return render(req,"manageProfile.html",{"data":data})


def editAdmin(req):
	return render(req,"editAdmin.html")


def error(req):
	return render(req,"error.html")


def editAdmin(request, id):
	admin = get_object_or_404(Admin, id=id)
	if request.method == "POST":
		admin.username = request.POST.get("username")
		admin.password = request.POST.get("password")
		admin.email = request.POST.get("email")
		admin.save()
		return redirect("/manageProfile")  # Redirect to patient list after updating
	return render(request, "editAdmin.html", {"admin": admin})

def aboutus(req):
    return render(req,"aboutus.html")