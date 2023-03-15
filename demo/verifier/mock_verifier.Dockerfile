FROM wiremock/wiremock

# Copy the stubs (canned API responses) into the image
COPY wiremock /home/wiremock
