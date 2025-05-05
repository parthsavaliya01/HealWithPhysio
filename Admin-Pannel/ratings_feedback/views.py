from django.shortcuts import render
from .models import RatingsFeedback

# Create your views here.
def ratings_feedback(req):
	displayData=RatingsFeedback.objects.all()
	dictData={"data":displayData}
	return render(req,"ratings_feedback.html",dictData)