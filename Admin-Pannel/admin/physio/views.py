from django.shortcuts import render ,get_object_or_404, redirect

from django.contrib import messages

from .models import Physiotherapist

# Create your views here.
def managePhysiotherapist(req):
	name=req.POST.get("name")
	username=req.POST.get("username")
	password=req.POST.get("password")
	contact_no=req.POST.get("contact_no")
	email=req.POST.get("email")
	gender=req.POST.get("gender")
	# photo=req.POST.get("photo")
	photo = req.FILES.get("photo")
	appartment=req.POST.get("appartment")
	landmark=req.POST.get("landmark")
	area=req.POST.get("area")
	city=req.POST.get("city")
	pincode=req.POST.get("pincode")
	clinic_start_time=req.POST.get("clinic_start_time")
	clinic_end_time=req.POST.get("clinic_end_time")
	qualification=req.POST.get("qualification")
	qualification_photo=req.POST.get("qualification_photo")
	qualification_photo=req.FILES.get("qualification_photo")
	specialization=req.POST.get("specialization")
	experience=req.POST.get("experience")
	average_rating=req.POST.get("average_rating")
	print(username,password,contact_no,email,gender,photo,appartment,landmark,area,city,pincode,qualification,qualification_photo,specialization,experience)
	
	saveData=Physiotherapist.objects.create(name=name,username=username,password=password,contact_no=contact_no,email=email,gender=gender,appartment=appartment,landmark=landmark,area=area,city=city,pincode=pincode,qualification=qualification,specialization=specialization,experience=experience,clinic_start_time=clinic_start_time,clinic_end_time=clinic_end_time,photo=photo,qualification_photo=qualification_photo,average_rating=average_rating)
	saveData.save()
	displayData=Physiotherapist.objects.all()
	dictData={"data":displayData}
	return render(req,"physiotherapist.html",dictData)


def addPhysiotherapist(req):
	return render(req,"addPhysiotherapist.html")


def editPhysiotherapist(req):
	return render(req,"editPhysiotherapist.html")


def physiotherapist(req):
	displayData=Physiotherapist.objects.all()
	dictData={"data":displayData}
	return render(req,"physiotherapist.html",dictData)


def deletePhysio(req,id):
	temp=Physiotherapist.objects.get(id=id)
	temp.delete()
	displayData=Physiotherapist.objects.all()
	dictData={"data":displayData}
	return render(req,"physiotherapist.html",dictData)


def editPhysio(request, id):
	physio = get_object_or_404(Physiotherapist, id=id)
	if request.method == "POST":
		physio.name=request.POST.get("name")
		physio.username = request.POST.get("username")
		physio.password = request.POST.get("password")
		physio.contact_no = request.POST.get("contact_no")
		physio.email = request.POST.get("email")
		physio.gender = request.POST.get("gender")
		# physio.photo = request.POST.get("photo")
		physio.photo = request.FILES.get("photo")
		physio.appartment = request.POST.get("appartment")
		physio.landmark = request.POST.get("landmark")
		physio.area = request.POST.get("area")
		physio.city = request.POST.get("city")
		physio.pincode = request.POST.get("pincode")
		physio.clinic_start_time = request.POST.get("clinic_start_time")
		physio.clinic_end_time = request.POST.get("clinic_end_time")
		physio.qualification = request.POST.get("qualification")
		# physio.qualification_photo = request.POST.get("qualification_photo")
		physio.qualification_photo = request.FILES.get("qualification_photo")
		physio.specialization = request.POST.get("specialization")
		physio.experience = request.POST.get("experience")
		physio.average_rating = request.POST.get("average_rating")
		physio.save()
		return redirect("/physiotherapist")  # Redirect to patient list after updating
	return render(request, "editPhysiotherapist.html", {"physio": physio})
