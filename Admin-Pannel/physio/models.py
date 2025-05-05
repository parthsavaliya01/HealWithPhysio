from django.db import models

# Create your models here.
class Physiotherapist(models.Model):
    id = models.AutoField(primary_key=True)
    name = models.CharField(null=True, max_length=30)
    username = models.CharField(null=True, max_length=20)
    password = models.CharField(null=True, max_length=15)
    contact_no = models.CharField(null=True, max_length=15)
    email = models.EmailField(null=True)
    gender_choices = [
        ('Male', 'Male'),
        ('Female', 'Female')
    ]
    gender = models.CharField(max_length=30, choices=gender_choices, null=True)
    photo = models.ImageField(upload_to='physio_photos/', default='default.jpg')
    appartment = models.CharField(null=True, max_length=20)
    landmark = models.CharField(null=True, max_length=20)
    area = models.CharField(null=True, max_length=20)
    city = models.CharField(null=True, max_length=20)
    pincode = models.IntegerField(null=True)
    clinic_start_time = models.TimeField(null=True)
    clinic_end_time = models.TimeField(null=True)
    qualification = models.CharField(null=True, max_length=50)
    qualification_photo = models.ImageField(upload_to='qualification_photos/', default='default.jpg')
    specialization = models.CharField(null=True, max_length=50)
    experience = models.IntegerField(null=True)
    average_rating=models.FloatField(default=0,null=True)
    
    def __str__(self):
        return self.username or "Unnamed Physiotherapist"