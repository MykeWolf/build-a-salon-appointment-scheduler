#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --no-align --tuples-only -c"
echo "~~~~~ MY SALON ~~~~~"
echo "Welcome to My Salon, how can I help you?"

# Function to display services
display_services() {
  SERVICES=$($PSQL "SELECT name FROM services;")
  echo "$SERVICES" | nl -w2 -s') '
}

# Display services from DB
display_services

# Get service ID from user
read SERVICE_ID_SELECTED
echo "$SERVICE_ID_SELECTED"

# CHECK IF SERVICE EXISTS
while [[ -z $($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;") ]]
do
  echo "I could not find that service. What would you like today?"
  display_services
  read SERVICE_ID_SELECTED
  echo "$SERVICE_ID_SELECTED"
done

# Ask user for phone number
read CUSTOMER_PHONE
echo "$CUSTOMER_PHONE"
# Check if customer exists
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# If not found, then ask for the customer's name
if [[ -z $CUSTOMER_ID ]]
then
  read CUSTOMER_NAME
  echo "$CUSTOMER_NAME"

  # Insert new customer into the customers table
  $PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"

  # Get the newly created customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
else
  # If customer exists, get their name for confirmation
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
fi

# Prompt for service time
echo "What time would you like your service, $CUSTOMER_NAME? "
read SERVICE_TIME
echo "$SERVICE_TIME"
# Insert appointment into appointments table
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Confirmation message
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
