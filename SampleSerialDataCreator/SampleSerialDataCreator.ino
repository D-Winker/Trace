void setup() {
  Serial.begin(115200);

}

void loop() {
  
  for (int i=0; i < 360; i++) {
    double rads = i * 3.14159 / 180;
    float val1 = sin(rads);
    float val2 = cos(rads);
    float val3 = sin(2*rads);
    float val4 = sin(2*rads);
    float val5 = sin(4*rads);
    Serial.print(val1); Serial.print(",");
    Serial.print(val2); Serial.print(",");
    Serial.print(val3); Serial.print(",");
    Serial.print(val4); Serial.print(",");
    Serial.println(val5);
    delay(50);
  }

}
