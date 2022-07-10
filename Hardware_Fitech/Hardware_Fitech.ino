#include <WiFiManager.h>
#include <IOXhop_FirebaseESP32.h>

#define irPin 2 //ESP32 pin GPIO2 IR SENSOR
#define trigPin 5 //ESP32 pin GPIO05 Ultrasonic trigger
#define echoPin 18 //ESP32 pin GPI18 Ultrasonic trigger

#define FIREBASE_Host "https://tryal-adf7d-default-rtdb.asia-southeast1.firebasedatabase.app/"  //Firebase Host
#define FIREBASE_authorization_key "2jQuI1i569aqqMrFXB4AURN3WFfQMm1GOX5LWxYi"  //Firebase secret key



int distance = 0;
unsigned long duration = 0;

//ir sensor
int count = 0;

boolean state = true;

//Firebase value saved
bool IR_state;
bool Ultrasonic_state;
int IR_count;
int sensor = 0;


WiFiServer wifiServer(80);

void setup() {

  WiFi.mode(WIFI_STA); // explicitly set mode, esp defaults to STA+AP
  // it is a good practice to make sure your code sets wifi mode how you want it.

  Serial.begin(115200);
  //WiFiManager, Local intialization. Once its business is done, there is no need to keep it around
  WiFiManager wm;

  // reset settings - wipe stored credentials for testing
  // these are stored by the esp library
  wm.resetSettings();

  // Automatically connect using saved credentials,
  // if connection fails, it starts an access point with the specified name ( "AutoConnectAP"),
  // if empty will auto generate SSID, if password is blank it will be anonymous AP (wm.autoConnect())
  // then goes into a blocking loop awaiting configuration and will return success result

  bool res;
  // res = wm.autoConnect(); // auto generated AP name from chipid
  // res = wm.autoConnect("AutoConnectAP"); // anonymous ap
  res = wm.autoConnect("FiTechConnect", "password"); // password protected ap

  if (!res) {
    Serial.println("Failed to connect");
    // ESP.restart();
  }
  else {
    //if you get here you have connected to the WiFi
    Serial.println("FiTech connected :)");
  }
  Firebase.begin(FIREBASE_Host, FIREBASE_authorization_key);

  pinMode(irPin, INPUT); //IR sensor
  pinMode(trigPin, OUTPUT); //Ultrasonic sensor
  pinMode(echoPin, INPUT); //Ultrasonic sensor
}

//Ultrasonic sensor
//Ultrasonic Distance
void logdistance() {
  // Clears the trigPin
  digitalWrite(trigPin, LOW);
  delayMicroseconds(2);

  // Sets the trigPin on HIGH state for 10 micro seconds
  digitalWrite(trigPin, HIGH);
  delayMicroseconds(10);
  digitalWrite(trigPin, LOW);

  // Reads the echoPin, returns the sound wave travel time in microseconds
  duration = pulseIn(echoPin, HIGH);

  // Calculating the distance
  distance = duration * 0.034 / 2;

  // Prints the distance on the Serial Monitor
  Serial.print("Distance: ");
  Serial.println(distance);
  delay(10);
  Firebase.setString("11t7y/warning", "OK"); //11t7y = device product id
    if (distance <= 7){
      Firebase.setString("11t7y/warning", "Move Further");
      }
}

//IR sensor
//Count banyak gerakan (ex: push up)
void IRsensor() {
  if (!digitalRead(irPin) && state) {
    count++;
    state = false;
    Serial.print("Count: ");
    Serial.println(count);
    delay(100);
  }
  if (digitalRead(irPin)) {
    state = true;
    delay(100);
  }

}

//data IR_state, Ultrasonic_state dan Piezo_state
//execute count IR sensor atau warning ultrasonic
void loop() {

  sensor = Firebase.getInt("11t7y/sensor"); //11t7y = device product id

  switch (sensor) {
    case 1:
      Firebase.setBool("11t7y/IR_state", true);
      Firebase.setBool("11t7y/Ultrasonic_state", false);

      while (sensor == 1) {
        sensor = Firebase.getInt("11t7y/sensor");
        IRsensor();
        Firebase.setInt("11t7y/IR_count", count);
      }

      //handle
      if (Firebase.failed()) {
        Serial.println("Sending data failed");
        Serial.println(Firebase.error());
        Firebase.setBool("11t7y/IR_state", false);
      }

    case 2:
      //activate ultrasonic on firebase
      Firebase.setBool("11t7y/Ultrasonic_state", true);
      Firebase.setBool("11t7y/IR_state", false);

      while (sensor == 2) {
        sensor = Firebase.getInt("11t7y/sensor");
        logdistance();
        Firebase.setInt("11t7y/Ultra_distance", distance);
        delay(500);
      }
      delay(1000);

      //handle
      if (Firebase.failed()) {
        Serial.println("Sending data failed");
        Serial.println(Firebase.error());
        Firebase.setBool("11t7y/IR_state", false);
      }

    default:
      Firebase.setBool("11t7y/IR_state", false);
      Firebase.setInt("11t7y/IR_count", 0);
      Firebase.setBool("11t7y/Ultrasonic_state", false);
      break;

  }


}
