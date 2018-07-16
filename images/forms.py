from django import forms
from .models import Image
from urllib import request
from django.core.files.base import ContentFile
from django.utils.text import slugify

class ImageCreateForm(forms.ModelForm):
    class Meta:
        model = Image
        fields = ('title', 'url', 'description')


    def clean_url(self):
        url = self.cleaned_data['url']
        valid_extensions = ['jpg', 'jpeg']
        extension = url.rsplit('.', 1)[1].lower()
        if extension not in valid_extensions:
            raise forms.ValidationError('The given URL does not ' \
                                        'match valid image extensions.')
        return url

    def save(self, force_insert=False,
             force_update=False,
             commit=True):
        images = super(ImageCreateForm, self).save(commit=False)    #every objects in modelform is loaded.
        image_url = self.cleaned_data['url']
        image_name = '{}.{}'.format(slugify(images.title),
                                    image_url.rsplit('.', 1)[1].lower())

        # download image from the given URL
        response = request.urlopen(image_url)
        images.image.save(image_name,
                         ContentFile(response.read()),
                         save=False)
        if commit:
            images.save()
        return images