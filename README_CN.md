# auto_electricity_bill_query

自动查询tqdianbiao电费，并进行电费监控的flutter app，目前只实现了android端

## 快速开始
```cmd
flutter pub get --no-example
flutter run --debug -d your_device_id
```

## 教程
1. 设置缴费链接(扫码或识别图片)和刷新规则
<img src="https://github.com/user-attachments/assets/a40226d5-0d11-4a40-b579-2c0f9294b9ef" width='300' alt="image1" />
<img src='https://github.com/user-attachments/assets/6bc7d31d-7f4b-4549-bbdf-7390b73d0062' width='300' alt='image2' />

2. 开启前台任务监控电费，到达设定电费阈值时将会通知
<img src="https://github.com/user-attachments/assets/fbd3214a-f141-44b6-b44d-742f4e6e029a" width="300" alt="image3" />

## 特性
- 前台任务的刷新时间固定是10min
- 当未开启前台任务监控电费时，app内存在一个后台任务刷新电费
- 设置刷新规则的刷新间隔是后台任务的间隔
- 由于国内安卓厂商限制，后台任务执行成功的概率非常低，最好使用前台监控
- 为避免误杀死监控进程，推荐在【任务管理】中锁定应用
<img src='https://github.com/user-attachments/assets/57447f06-e2d4-480b-b8bb-94f0e47092df' width='300' alt='image4' />

## 更多
- 后续准备实现电费使用报表
- 期待有伙伴帮忙实现一下ios部分！
