from django.db import models

# Create your models here.

class Admin(models.Model):
	id=models.AutoField(primary_key=True)
	username=models.CharField(max_length=20)
	password=models.CharField(max_length=15)
	email=models.EmailField()
	def __str__(self):
		return self.username

	