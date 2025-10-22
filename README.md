# auto_electricity_bill_query

A Flutter app for automatic TQDianBiao electricity bill query and monitoring, currently available only for the Android platform.

## Quick Start
```cmd
flutter pub get
flutter run --debug -d your_device_id
```

## Tutorial
1. Set up the payment link (via QR code scanning or image recognition) and refresh rules
<img src="https://github.com/user-attachments/assets/a40226d5-0d11-4a40-b579-2c0f9294b9ef" width='300' alt="image1" />
<img src='https://github.com/user-attachments/assets/6bc7d31d-7f4b-4549-bbdf-7390b73d0062' width='300' alt='image2' />

2. Enable the foreground service to monitor electricity bills. You will receive a notification when the bill reaches the set threshold.
<img src="https://github.com/user-attachments/assets/fbd3214a-f141-44b6-b44d-742f4e6e029a" width="300" alt="image3" />

## Features
- The refresh interval for the foreground service is fixed at 10 minutes.
- When the foreground monitoring service is disabled, a background task in the app will still refresh the electricity bill.
- The "refresh interval" set in the rules applies to the background task.
- Due to restrictions from domestic Android manufacturers, the background task has a very low success rate. Using the foreground monitoring service is highly recommended.
- To prevent the monitoring process from being accidentally killed, it is recommended to lock the app in [Task Manager].
<img src='https://github.com/user-attachments/assets/57447f06-e2d4-480b-b8bb-94f0e47092df' width='300' alt='image4' />

## More
- Plans for future updates: Adding an electricity consumption report feature.
- Welcome contributors to help implement the iOS version!
