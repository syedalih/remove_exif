import json
import boto3
import os
from PIL import Image

def lambda_handler(event, context):
    print ('Event: %s', event)

    dest_bucket = os.environ['DESTINATION_BUCKET']
    source_bucket = event['Records'][0]['s3']['bucket']['name']
    key_name = event['Records'][0]['s3']['object']['key']

    #download the image
    print ("downloading image %s" % key_name)
    s3 = boto3.client('s3')
    download_path = os.path.join('/tmp', 'myfile.jpg')
    s3.download_file(source_bucket, key_name, download_path)

    #remove exif
    print ("Removing EXIF data from %s" % key_name)
    image = Image.open(download_path)
    data = list(image.getdata())
    no_exif = Image.new(image.mode, image.size)
    no_exif.putdata(data)
    new_file_path = os.path.join('/tmp', 'no_exif.jpg')
    no_exif.save(new_file_path)

    #upload to the other bucket
    print ("uploading %s to S3 bucket %s as %s" % (new_file_path, dest_bucket, key_name))
    s3_resource = boto3.resource('s3')
    s3_resource.meta.client.upload_file(Filename=new_file_path, Bucket=dest_bucket, Key=key_name)