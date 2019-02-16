package com.example.activityandintents;

import android.content.Intent;
import android.os.Bundle;
import android.support.design.widget.FloatingActionButton;
import android.support.design.widget.Snackbar;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.widget.Toolbar;
import android.view.View;
import android.widget.Button;
import android.widget.TextView;

public class SecondActitity extends AppCompatActivity {

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_second_actitity);

        Intent myIntent = getIntent();

        Button b = findViewById(R.id.SecondActivityBtn);
        TextView tv = findViewById(R.id.textView);
        String str1= myIntent.getStringExtra("FirstKey");
        String str2= myIntent.getStringExtra("SecondKey");
        tv.setText(str1+str2);
        b.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent navigateToNextPage = new Intent(v.getContext(),MainActivity.class);
                navigateToNextPage.putExtra("FirstKey","This message is from SecondActivity");
                navigateToNextPage.putExtra("SecondKey","Hello Om");
                startActivity(navigateToNextPage);

            }
        });
    }

}


