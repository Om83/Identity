package com.example.activityandintents;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class MainActivity extends AppCompatActivity {
    static final int PICK_CONTACT_REQUEST = 1;  // The request code


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        Intent myIntent = getIntent();

        Button b = findViewById(R.id.SecondActivityBtn);
        TextView tv = findViewById(R.id.MainActivityTextView);
        String str1= myIntent.getStringExtra("FirstKey");
        String str2= myIntent.getStringExtra("SecondKey");
        tv.setText(str1+str2);

        Button b1 = findViewById(R.id.MainActivityBtn);
        String msg = "This message is from Main Activity";
        b1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent navigateToNextPage = new Intent(v.getContext(),SecondActitity.class);
                navigateToNextPage.putExtra("FirstKey","This message is from MainActivity");
                navigateToNextPage.putExtra("SecondKey","This is additional message");
                startActivity(navigateToNextPage);

            }
        });
    }
    


}
