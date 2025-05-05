from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator

class RatingsFeedback(models.Model):
    id = models.AutoField(primary_key=True)
    appointment_id = models.ForeignKey(
        'appointment.Appointment',
        on_delete=models.CASCADE,
        db_column='appointment_id'
    )
    physio_name = models.CharField(max_length=200)
    patient_name = models.CharField(max_length=200)
    rating = models.IntegerField(
        choices=[(i, i) for i in range(1, 6)],
        validators=[MinValueValidator(1), MaxValueValidator(5)]
    )
    feedback = models.TextField(null=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        db_table = 'ratings_feedback'
        app_label = 'ratings_feedback'