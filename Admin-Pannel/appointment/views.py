from django.shortcuts import render
from django.shortcuts import render, get_object_or_404, redirect


from .models import Appointment

# Create your views here.
def appointment(req):
	displayData=Appointment.objects.all()
	dictData={"data":displayData}
	return render(req,"appointment.html",dictData)

def manageAppointment(req):
	physio_name=req.POST.get("physio_name")
	contact_number=req.POST.get("contact_number")
	email=req.POST.get("email")
	gender=req.POST.get("gender")
	specialization=req.POST.get("specialization")
	booking_date=req.POST.get("booking_date")
	status=req.POST.get("status")
	appointment_date=req.POST.get("appointment_date")
	consulting_type=req.POST.get("consulting_type")
	selected_slot=req.POST.get("selected_slot")
	is_emergency=req.POST.get("is_emergency")
	appartment=req.POST.get("appartment")
	landmark=req.POST.get("landmark")
	area=req.POST.get("area")
	city=req.POST.get("city")
	pincode=req.POST.get("pincode")
	patient_name=req.POST.get("patient_name")
	patient_contactno=req.POST.get("patient_contactno")
	patient_email=req.POST.get("patient_email")
	patient_gender=req.POST.get("patient_gender")
	rejection_reason=req.POST.get("rejection_reason")

	saveData=Appointment.objects.create(physio_name=physio_name,contact_number=contact_number,email=email,gender=gender,specialization=specialization,booking_date=booking_date, status=status,appointment_date=appointment_date, consulting_type=consulting_type,selected_slot=selected_slot,is_emergency=is_emergency,appartment=appartment,landmark=landmark,area=area,city=city,pincode=pincode,patient_name=patient_name,patient_contactno=patient_contactno,patient_email=patient_email,patient_gender=patient_gender,rejection_reason=rejection_reason)
	saveData.save()
	displayData=Appointment.objects.all()
	dictData={"data":displayData}
	return render(req,"appointment.html",dictData)

def addAppointment(req):
	return render(req,"addAppointment.html")


def deleteAppointment(req,id):
	temp=Appointment.objects.get(id=id)
	temp.delete()
	displayData=Appointment.objects.all()
	dictData={"data":displayData}
	return render(req,"appointment.html",dictData)

def editAppointment(request):
	return render(request,"editAppointment.html")

	
def editAppointment(req, id):
	appointment = get_object_or_404(Appointment, id=id)
	if req.method == "POST":
		appointment.physio_name=req.POST.get("physio_name")
		appointment.contact_number=req.POST.get("contact_number")
		appointment.email=req.POST.get("email")
		appointment.gender=req.POST.get("gender")
		appointment.specialization=req.POST.get("specialization")
		appointment.booking_date=req.POST.get("booking_date")
		appointment.status=req.POST.get("status")
		appointment.appointment_date=req.POST.get("appointment_date")
		appointment.consulting_type=req.POST.get("consulting_type")
		appointment.selected_slot=req.POST.get("selected_slot")
		appointment.is_emergency=req.POST.get("is_emergency")
		appointment.appartment=req.POST.get("appartment")
		appointment.landmark=req.POST.get("landmark")
		appointment.area=req.POST.get("area")
		appointment.city=req.POST.get("city")
		appointment.pincode=req.POST.get("pincode")
		appointment.patient_name=req.POST.get("patient_name")
		appointment.patient_contactno=req.POST.get("patient_contactno")
		appointment.patient_email=req.POST.get("patient_email")
		appointment.patient_gender=req.POST.get("patient_gender")
		appointment.rejection_reason=req.POST.get("rejection_reason")
		appointment.save()
		return redirect("/appointment")  # Redirect to patient list after updating
	return render(req, "editAppointment.html", {"appointment": appointment})
