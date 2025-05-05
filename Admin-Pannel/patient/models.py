from django.db import models

# Create your models here.
class Patient(models.Model):
	id=models.AutoField(primary_key=True)
	name=models.CharField(null=True,max_length=30)
	username=models.CharField(null=True,max_length=20)
	password=models.CharField(null=True,max_length=15)
	contact_no=models.CharField(null=True,max_length=15)
	email=models.EmailField(null=True)
	gender_choices=[
		('Male','Male'),
		('Female','Female')
	]
	gender=models.CharField(null=True,max_length=30,choices=gender_choices)
	appartment=models.CharField(null=True,max_length=20)
	landmark=models.CharField(null=True,max_length=20)
	area=models.CharField(null=True,max_length=20)
	city=models.CharField(null=True,max_length=20)
	pincode=models.IntegerField(null=True)
	def __str__(self):
		return self.username or "Unnamed Patient"