from django.shortcuts import render, get_object_or_404, redirect
from django.contrib import messages

from .models import Patient

# Create your views here.
def managePatient(req):
	name=req.POST.get("name")
	username=req.POST.get("username")
	password=req.POST.get("password")
	contact_no=req.POST.get("contact_no")
	email=req.POST.get("email")
	gender=req.POST.get("gender")
	appartment=req.POST.get("appartment")
	landmark=req.POST.get("landmark")
	area=req.POST.get("area")
	city=req.POST.get("city")
	pincode=req.POST.get("pincode")
	print(username,password,contact_no,email,gender,appartment,landmark,area,city,pincode)

	saveData=Patient.objects.create(name=name,username=username,password=password,contact_no=contact_no,email=email,gender=gender,appartment=appartment,landmark=landmark,area=area,city=city,pincode=pincode)
	saveData.save()
	displayData=Patient.objects.all()
	dictData={"data":displayData}
	return render(req,"patient.html",dictData)

def addPatient(req):
	return render(req,"addPatient.html")


def editPatient(req):
	return render(req,"editPatient.html")

def patient(req):
	displayData=Patient.objects.all()
	dictData={"data":displayData}
	return render(req,"patient.html",dictData)


def deletePatient(req,id):
	temp=Patient.objects.get(id=id)
	temp.delete()
	displayData=Patient.objects.all()
	dictData={"data":displayData}
	return render(req,"patient.html",dictData)


def editPatient(request, id):
	patient = get_object_or_404(Patient, id=id)
	if request.method == "POST":
		patient.name=request.POST.get("name")
		patient.username = request.POST.get("username")
		patient.password = request.POST.get("password")
		patient.contact_no = request.POST.get("contact_no")
		patient.email = request.POST.get("email")
		patient.gender = request.POST.get("gender")
		patient.appartment = request.POST.get("appartment")
		patient.landmark = request.POST.get("landmark")
		patient.area = request.POST.get("area")
		patient.city = request.POST.get("city")
		patient.pincode = request.POST.get("pincode")
		patient.save()
		return redirect("/patient")  # Redirect to patient list after updating
	return render(request, "editPatient.html", {"patient": patient})
