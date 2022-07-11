#include <WiFiManager.h>
#include <IOXhop_FirebaseESP32.h>

#define irPin 2 //ESP32 pin GPIO2 IR SENSOR
#define trigPin 5 //ESP32 pin GPIO18 Ultrasonic trigger
#define echoPin 18 //ESP32 pin GPIO5 Ultrasonic trigger


#define FIREBASE_Host "https://tryal-adf7d-default-rtdb.asia-southeast1.firebasedatabase.app/"  // replace with your Firebase Host
#define FIREBASE_authorization_key "secret key"  // replace with your secret key


/*ultrasonic (    Connect the VCC pin to 3.3V on the ESP32
                  Connect the GND pin to ground on the ESP32
                  Connect the Trig pin to D2 on the ESP32
                  Connect the Echo pin to D5 on the ESP32*/

int distance = 0;
unsigned long duration = 0;


//IR Sensor
int count = 0;
boolean state = true;


//Firebase value saved
bool IR_state;
bool Piezo_state;
bool Ultrasonic_state;
int IR_count;
int sensor = 0;


WiFiServer wifiServer(80);

void setup() {
  
  //WiFiManager Library
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
  pinMode(beepPin, OUTPUT); //Piezo electri buzzer
}

//Ultrasonic sensor Algorithm
//Mengecek jarak antara user dengan hardware (to check distance between user and hardware)
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
  Firebase.setString("esp32/warning", "OK");
    if (distance <= 7){
      Firebase.setString("esp32/warning", "Move Further");
      }
}

//IR sensor
//Nge-count banyaknya gerakan (to count movements made by user)
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

//Reading Firebase data
//Execute IR sensor or Ultrasonic sensor
void loop() {

  sensor = Firebase.getInt("esp32/sensor");

  switch (sensor) {
    case 1: 
      //Execute and set IR sensor TRUE on firebase
      Firebase.setBool("esp32/IR_state", true);
      Firebase.setBool("esp32/Ultrasonic_state", false);

      while (sensor == 1) {
        sensor = Firebase.getInt("esp32/sensor");
        IRsensor();
        Firebase.setInt("esp32/IR_count", count);
      }

      //handle
      if (Firebase.failed()) {
        Serial.println("Sending data failed");
        Serial.println(Firebase.error());
        Firebase.setBool("esp32/IR_state", false);
      }

    case 2:
      //Execute and set Ultrasonic sensor TRUE on firebase
      Firebase.setBool("esp32/Ultrasonic_state", true);
      Firebase.setBool("esp32/IR_state", false);

      while (sensor == 2) {
        sensor = Firebase.getInt("esp32/sensor");
        logdistance();
        Firebase.setInt("esp32/Ultra_distance", distance);
        delay(500);
      }
      delay(1000);

      //handle
      if (Firebase.failed()) {
        Serial.println("Sending data failed");
        Serial.println(Firebase.error());
        Firebase.setBool("esp32/IR_state", false);
      }

    //execute default if sensor value except 1 or 2
    default:
      Firebase.setBool("esp32/IR_state", false);
      Firebase.setInt("esp32/IR_count", 0);
      Firebase.setBool("esp32/Ultrasonic_state", false);
      break;

  }


}
