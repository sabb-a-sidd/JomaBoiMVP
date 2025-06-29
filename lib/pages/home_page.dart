import 'package:events_emitter/events_emitter.dart';
import 'package:jomaboi/bloc/cubit/app_cubit.dart';
import 'package:jomaboi/dao/account_dao.dart';
import 'package:jomaboi/dao/payment_dao.dart';
import 'package:jomaboi/events.dart';
import 'package:jomaboi/models/account.model.dart';

//import 'package:jomaboi/model/group.model.dart';
import 'package:jomaboi/models/category.model.dart';

import 'package:jomaboi/models/payment.model.dart';
import 'package:jomaboi/widgets/account_slider.dart';
import 'package:jomaboi/widgets/payment_list_item.dart';
import 'package:jomaboi/pages/payment_form.screen.dart';
import 'package:jomaboi/theme/colors.dart';
import 'package:jomaboi/widgets/currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

String greeting() {
  var hour = DateTime.now().hour;
  if (hour < 12) {
    return 'Morning';
  }
  if (hour < 17) {
    return 'Afternoon';
  }
  return 'Evening';
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomePage> {
  final PaymentDao _paymentDao = PaymentDao();
  final AccountDao _accountDao = AccountDao();
  EventListener? _accountEventListener;

  EventListener? _groupEventListener;
  EventListener? _categoryEventListener;

  EventListener? _paymentEventListener;
  List<Payment> _payments = [];
  List<Account> _accounts = [];
  double _income = 0;
  double _expense = 0;
  //double _savings = 0;
  DateTimeRange _range = DateTimeRange(
      start: DateTime.now().subtract(Duration(days: DateTime.now().day - 1)),
      end: DateTime.now());
  Account? _account;
  Category? _category;

  void openAddPaymentPage(PaymentType type) async {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (builder) => PaymentForm(type: type)));
  }

  void handleChooseDateRange() async {
    final selected = await showDateRangePicker(
      context: context,
      initialDateRange: _range,
      firstDate: DateTime(2019),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _range = selected;
        _fetchTransactions();
      });
    }
  }

  bool _isLoading = false;

  void _fetchTransactions() async {
    if (_isLoading) return; // Prevent multiple simultaneous fetches

    setState(() {
      _isLoading = true;
    });

    try {
      // Fetch transactions
      List<Payment> trans = await _paymentDao.find(
          range: _range, category: _category, account: _account);
      
      // Calculate totals
      double income = 0;
      double expense = 0;
      for (var payment in trans) {
        if (payment.type == PaymentType.credit) income += payment.amount;
        if (payment.type == PaymentType.debit) expense += payment.amount;
      }

      // Fetch accounts
      List<Account> accounts = await _accountDao.find(withSummery: true);

      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          _payments = trans;
          _income = income;
          _expense = expense;
          _accounts = accounts;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching transactions: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading data. Please try again.')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchTransactions();

    _accountEventListener = globalEvent.on("account_update", (data) {
      debugPrint("accounts are changed");
      _fetchTransactions();
    });

    _categoryEventListener = globalEvent.on("category_update", (data) {
      debugPrint("categories are changed");
      _fetchTransactions();
    });

    _groupEventListener = globalEvent.on("group_update", (data) {
      debugPrint("groups are changed");
      _fetchTransactions();
    });

    _paymentEventListener = globalEvent.on("payment_update", (data) {
      debugPrint("payments are changed");
      _fetchTransactions();
    });
  }

  @override
  void dispose() {
    _accountEventListener?.cancel();
    _categoryEventListener?.cancel();
    _groupEventListener?.cancel();
    _paymentEventListener?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: const Icon(Icons.menu),
      //     onPressed: (){
      //       Scaffold.of(context).openDrawer();
      //     },
      //   ),
      //   title: const Text("Home", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),),
      // ),
      body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin:
                const EdgeInsets.only(left: 15, right: 15, bottom: 15, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Hi! Good ${greeting()}"),
                    BlocConsumer<AppCubit, AppState>(
                        listener: (context, state) {},
                        builder: (context, state) => Text(
                          state.username ?? "Guest",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w600),
                        ))
                  ],
                ),
              ),
              AccountsSlider(
                accounts: _accounts,
              ),
              const SizedBox(
                height: 15,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Row(children: [
                  const Text("Payments",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17)),
                  const Expanded(child: SizedBox()),
                  MaterialButton(
                    onPressed: () {
                      handleChooseDateRange();
                    },
                    height: double.minPositive,
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    child: Row(
                      children: [
                        Text(
                          "${DateFormat("dd MMM").format(_range.start)} - ${DateFormat("dd MMM").format(_range.end)}",
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const Icon(Icons.arrow_drop_down_outlined)
                      ],
                    ),
                  ),
                ]),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: ThemeColors.success.withOpacity(0.2),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(TextSpan(children: [
                                    //TextSpan(text: "▼", style: TextStyle(color: ThemeColors.success)),
                                    TextSpan(
                                        text: "Income",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ])),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CurrencyText(
                                    _income,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.success),
                                  )
                                ],
                              ),
                            ))),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                        child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              color: ThemeColors.error.withOpacity(0.2),
                            ),
                            child: SizedBox(
                              width: double.infinity,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text.rich(TextSpan(children: [
                                    //TextSpan(text: "▲", style: TextStyle(color: ThemeColors.error)),
                                    TextSpan(
                                        text: "Expense",
                                        style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600)),
                                  ])),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  CurrencyText(
                                    _expense,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: ThemeColors.error),
                                  )
                                ],
                              ),
                            ))),
                  ],
                ),
              ),
              _payments.isNotEmpty
                  ? ListView.separated(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemBuilder: (BuildContext context, index) {
                  return PaymentListItem(
                      payment: _payments[index],
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (builder) => PaymentForm(
                              type: _payments[index].type,
                              payment: _payments[index],
                            )));
                      });
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Container(
                    width: double.infinity,
                    color: Colors.grey.withAlpha(25),
                    height: 1,
                    margin: const EdgeInsets.only(left: 75, right: 20),
                  );
                },
                itemCount: _payments.length,
              )
                  : Container(
                padding: const EdgeInsets.symmetric(vertical: 25),
                alignment: Alignment.center,
                child: const Text("No payments!"),
              ),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => openAddPaymentPage(PaymentType.credit),
        child: const Icon(Icons.add),
      ),
    );
  }
}
