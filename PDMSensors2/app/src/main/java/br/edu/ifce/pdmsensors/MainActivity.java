package br.edu.ifce.pdmsensors;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Bundle;
import android.widget.Button;
import android.widget.TextView;

import androidx.activity.EdgeToEdge;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.graphics.Insets;
import androidx.core.view.ViewCompat;
import androidx.core.view.WindowInsetsCompat;

public class MainActivity extends AppCompatActivity implements SensorEventListener {

    private Sensor mSensor;
    private SensorManager sensorManager;
    private String dadosAcelerometro = "";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        EdgeToEdge.enable(this);
        setContentView(R.layout.activity_main);
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.main), (v, insets) -> {
            Insets systemBars = insets.getInsets(WindowInsetsCompat.Type.systemBars());
            v.setPadding(systemBars.left, systemBars.top, systemBars.right, systemBars.bottom);
            return insets;
        });

        TextView lblAcelerometroData = (TextView) findViewById(R.id.lblAcelerometroDados);
        Button btnCapturarDados = (Button) findViewById(R.id.btnCaputrarDados);

        sensorManager = (SensorManager) getSystemService(Context.SENSOR_SERVICE);
        mSensor = null;

        if (sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER) != null){
            mSensor = sensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
            sensorManager.registerListener(MainActivity.this, mSensor, SensorManager.SENSOR_DELAY_NORMAL);
        } else{
            System.err.println("Acelerômetro não disponível!");
        }

        btnCapturarDados.setOnClickListener(v -> {
            lblAcelerometroData.setText(dadosAcelerometro);
        });
    }

    @Override
    public void onSensorChanged(SensorEvent event) {
        float x = event.values[0];
        float y = event.values[1];
        float z = event.values[2];
        dadosAcelerometro = String.format("X: %.2f\nY: %.2f\nZ: %.2f", x, y, z);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int accuracy) {

    }
}