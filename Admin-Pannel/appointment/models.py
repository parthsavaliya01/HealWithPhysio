from django.db import models
from datetime import datetime, time
from django.utils import timezone


class Appointment(models.Model):
    id = models.AutoField(primary_key=True)

    class Meta:
        db_table = 'appointments'

    physio_name = models.CharField(null=True, max_length=30)
    contact_number = models.CharField(null=True, max_length=20)
    email = models.EmailField(null=True)
    
    GENDER_CHOICES = [
        ('Male', 'Male'),
        ('Female', 'Female'),
    ]
    gender = models.CharField(null=True, max_length=10, choices=GENDER_CHOICES)
    
    specialization = models.CharField(null=True, max_length=30)
    booking_date = models.DateTimeField(default=timezone.now, null=True)    
    STATUS_CHOICES = [
        ('Accepted', 'Accepted'),
        ('Rejected', 'Rejected'),
        ('Pending', 'Pending'),
    ]
    status = models.CharField(null=True, max_length=30, choices=STATUS_CHOICES)
    
    appointment_date = models.DateField(null=True)
    
    CONSULTING_CHOICES = [
        ('Home Visit', 'Home Visit'),
        ('Clinic Visit', 'Clinic Visit'),
    ]
    consulting_type = models.CharField(null=True, max_length=30, choices=CONSULTING_CHOICES)
    
    selected_slot = models.CharField(null=True, max_length=100)
    is_emergency = models.IntegerField(null=True)
    appartment = models.CharField(null=True, max_length=50)
    landmark = models.CharField(null=True, max_length=30)
    area = models.CharField(null=True, max_length=30)
    city = models.CharField(null=True, max_length=30)
    pincode = models.IntegerField(null=True)
    patient_name = models.CharField(null=True, max_length=30)
    patient_contactno = models.CharField(null=True, max_length=20)
    patient_email = models.EmailField(null=True)
    
    PATIENT_GENDER_CHOICES = [
        ('Male', 'Male'),
        ('Female', 'Female'),
    ]
    patient_gender = models.CharField(null=True, max_length=10, choices=PATIENT_GENDER_CHOICES)
    
    rejection_reason = models.CharField(null=True, max_length=100)