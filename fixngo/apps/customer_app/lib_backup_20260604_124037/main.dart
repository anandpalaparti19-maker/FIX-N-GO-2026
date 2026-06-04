import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'config/api_config.dart';
import 'services/api_service.dart';
import 'services/storage_service.dart';

void main() => runApp(const FixNGoApp());

// ═══════════════════════════════════════════
//  DESIGN TOKENS
// ═══════════════════════════════════════════
class AppColors {
  static const black = Color(0xFF0C0C0C);
  static const white = Color(0xFFFFFFFF);
  static const off = Color(0xFFF5F5F5);
  static const off2 = Color(0xFFEBEBEB);
  static const border = Color(0xFFE2E2E2);
  static const muted = Color(0xFF9B9B9B);
  static const dark2 = Color(0xFF1A1A1A);
  static const red = Color(0xFFFF2D2D);
  static const green = Color(0xFF00C853);
  static const yellow = Color(0xFFFFC107);
  static const blue = Color(0xFF1A56FF);
}

class ResponsiveUtils {
  static double getScaleFactor(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w < 360) return 0.82;
    if (w < 390) return 0.92;
    if (w < 460) return 0.98;
    if (w < 600) return 1.0;
    if (w < 900) return 1.08;
    return 1.16;
  }

  static double scaledPadding(BuildContext context, double base) =>
      base * getScaleFactor(context);

  static bool isSmallPhone(BuildContext context) =>
      MediaQuery.of(context).size.width < 360;
}

class AppFonts {
  static double _s(BuildContext? ctx) =>
      ctx != null ? ResponsiveUtils.getScaleFactor(ctx) : 1.0;

  static TextStyle display({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w800,
    Color color = AppColors.black,
    double? letterSpacing,
    double? height,
    BuildContext? context,
  }) =>
      GoogleFonts.outfit(
        fontSize: fontSize * _s(context),
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle body({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.black,
    double? letterSpacing,
    double? height,
    BuildContext? context,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize * _s(context),
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        height: height,
      );

  static TextStyle label({
    Color color = AppColors.muted,
    double fontSize = 10,
    BuildContext? context,
  }) =>
      GoogleFonts.nunito(
        fontSize: fontSize * _s(context),
        fontWeight: FontWeight.w700,
        color: color,
        letterSpacing: 1.2,
      );
}

// ═══════════════════════════════════════════
//  DATA MODELS
// ═══════════════════════════════════════════
class Brand {
  final String name;
  final String emoji;
  final List<String> models;

  const Brand({
    required this.name,
    required this.emoji,
    required this.models,
  });
}

class Issue {
  final String name;
  final String emoji;
  final String description;
  final int price;

  const Issue({
    required this.name,
    required this.emoji,
    required this.description,
    required this.price,
  });
}

class Technician {
  final String name;
  final String emoji;
  final String rating;
  final String experience;
  final String eta;
  final String distance;
  final int jobs;

  const Technician({
    required this.name,
    required this.emoji,
    required this.rating,
    required this.experience,
    required this.eta,
    required this.distance,
    required this.jobs,
  });
}

class Order {
  final String rawId;
  final String id;
  final String brand;
  final String model;
  final List<String> issues;
  final String techName;
  final String date;
  final String status;
  final int total;
  final List<Map<String, dynamic>> statusHistory;

  const Order({
    required this.rawId,
    required this.id,
    required this.brand,
    required this.model,
    required this.issues,
    required this.techName,
    required this.date,
    required this.status,
    required this.total,
    this.statusHistory = const [],
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final created = json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'].toString())
        : null;
    final dateStr = created != null
        ? '${created.day} ${_month(created.month)} ${created.year}'
        : '—';
    final rawId = json['_id']?.toString() ?? '';
    final techName = json['technicianName']?.toString() ??
        json['technician']?.toString() ??
        (json['technicianUser'] is Map ? json['technicianUser']['name']?.toString() : null) ??
        '—';
    return Order(
      rawId: rawId,
      id: rawId.isNotEmpty ? '#${rawId.substring(rawId.length > 6 ? rawId.length - 6 : 0).toUpperCase()}' : '#—',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      issues: (json['issues'] as List?)?.map((e) => e.toString()).toList() ?? [],
      techName: techName,
      date: dateStr,
      status: json['status']?.toString() ?? 'pending',
      total: (json['total'] as num?)?.toInt() ?? 0,
      statusHistory: (json['statusHistory'] as List?)
              ?.map((e) => Map<String, dynamic>.from(e as Map))
              .toList() ??
          [],
    );
  }

  static String _month(int m) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[m - 1];
  }
}

// ═══════════════════════════════════════════
//  APP STATE
// ═══════════════════════════════════════════
class AppState extends ChangeNotifier {
  final ApiService api = ApiService();
  final StorageService storage = StorageService();

  String currentScreen = 'login';
  String? selectedOrderId;
  bool isLoggedIn = false;
  bool isLoading = false;
  String? errorMessage;

  String userName = '';
  String userEmail = '';
  String userPhone = '+91 98765 43210';
  String userLocation = 'Kondapur, Hyderabad';

  String selBrand = '';
  String selModel = '';
  List<Issue> selIssues = [];
  int total = 0;
  String pickedTechName = '';
  String pickedEta = '12';
  String pickedRating = '4.9';

  List<Brand> brands = [];
  List<Issue> catalogIssues = [];
  List<Technician> technicians = [];
  List<Order> orders = [];

  Future<void> bootstrap() async {
    isLoading = true;
    notifyListeners();
    try {
      final session = await storage.getUser();
      if (session != null) {
        api.setToken(session['token']);
        userName = session['name'] ?? '';
        userEmail = session['email'] ?? '';
        isLoggedIn = true;
        currentScreen = 's1';
      }
      await loadCatalog();
      if (isLoggedIn) {
        await refreshProfile();
        await refreshOrders();
      }
    } catch (_) {
      errorMessage = 'Could not reach server at ${ApiConfig.baseUrl}';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadCatalog() async {
    final data = await api.getCatalog();
    brands = (data['brands'] as List? ?? [])
        .map((b) => Brand(
              name: b['name']?.toString() ?? '',
              emoji: b['emoji']?.toString() ?? '📱',
              models: (b['models'] as List?)?.map((m) => m.toString()).toList() ?? [],
            ))
        .toList();
    catalogIssues = (data['issues'] as List? ?? [])
        .map((i) => Issue(
              name: i['name']?.toString() ?? '',
              emoji: i['emoji']?.toString() ?? '🔧',
              description: i['description']?.toString() ?? '',
              price: (i['price'] as num?)?.toInt() ?? 0,
            ))
        .toList();
    notifyListeners();
  }

  Future<void> loadTechnicians() async {
    final list = await api.getTechnicians();
    technicians = list.map((t) {
      return Technician(
        name: t['name']?.toString() ?? '',
        emoji: t['emoji']?.toString() ?? '🛠️',
        rating: (t['rating']?.toString() ?? '4.8'),
        experience: t['experience']?.toString() ?? '',
        eta: t['eta']?.toString() ?? '',
        distance: t['distance']?.toString() ?? '',
        jobs: (t['jobs'] as num?)?.toInt() ?? 0,
      );
    }).toList();
    if (technicians.isNotEmpty) {
      pickedTechName = technicians.first.name;
      pickedEta = technicians.first.eta;
      pickedRating = technicians.first.rating;
    }
    notifyListeners();
  }

  Future<void> refreshOrders() async {
    final list = await api.getOrders();
    orders = list.map((o) => Order.fromJson(Map<String, dynamic>.from(o as Map))).toList();
    notifyListeners();
  }

  Future<void> refreshProfile() async {
    final profile = await api.getProfile();
    userName = profile['name']?.toString() ?? userName;
    userEmail = profile['email']?.toString() ?? userEmail;
    userPhone = profile['phone']?.toString() ?? userPhone;
    userLocation = profile['address']?.toString().isNotEmpty == true
        ? '${profile['address']}, ${profile['city'] ?? ''}'
        : userLocation;
    notifyListeners();
  }

  Future<bool> saveProfile({
    required String name,
    required String phone,
    required String address,
    required String city,
    required String pincode,
  }) async {
    try {
      final data = await api.updateProfile(
        name: name,
        phone: phone,
        address: address,
        city: city,
        pincode: pincode,
      );
      userName = data['name']?.toString() ?? name;
      userPhone = data['phone']?.toString() ?? phone;
      userLocation = address.isNotEmpty ? '$address, $city' : city;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      final data = await api.login(email, password);
      userName = data['name']?.toString() ?? '';
      userEmail = data['email']?.toString() ?? email;
      await storage.saveSession(
        token: data['token']?.toString() ?? '',
        name: userName,
        email: userEmail,
      );
      isLoggedIn = true;
      currentScreen = 's1';
      await refreshOrders();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String password) async {
    errorMessage = null;
    isLoading = true;
    notifyListeners();
    try {
      final data = await api.register(name, email, password);
      userName = data['name']?.toString() ?? name;
      userEmail = data['email']?.toString() ?? email;
      await storage.saveSession(
        token: data['token']?.toString() ?? '',
        name: userName,
        email: userEmail,
      );
      isLoggedIn = true;
      currentScreen = 's1';
      await refreshOrders();
      return true;
    } on ApiException catch (e) {
      errorMessage = e.message;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> submitOrder() async {
    final parts = userLocation.split(',');
    final address = parts.isNotEmpty ? parts.first.trim() : userLocation;
    final city = parts.length > 1 ? parts.sublist(1).join(',').trim() : 'Hyderabad';
    await api.createOrder(
      brand: selBrand,
      model: selModel,
      issues: selIssues.map((i) => i.name).toList(),
      total: total,
      technician: pickedTechName,
      customerPhone: userPhone,
      serviceAddress: address,
      city: city,
    );
    await refreshOrders();
  }

  void go(String screen) {
    currentScreen = screen;
    if (screen == 'orders' && isLoggedIn) {
      refreshOrders();
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await storage.clear();
    api.setToken(null);
    isLoggedIn = false;
    currentScreen = 'login';
    selBrand = '';
    selModel = '';
    selIssues = [];
    total = 0;
    orders = [];
    notifyListeners();
  }

  void selectBrand(String brand) {
    selBrand = brand;
    selModel = '';
    notifyListeners();
  }

  void selectModel(String model) {
    selModel = model;
    notifyListeners();
  }

  void toggleIssue(Issue issue) {
    final idx = selIssues.indexWhere((i) => i.name == issue.name);
    if (idx == -1) {
      selIssues.add(issue);
      total += issue.price;
    } else {
      selIssues.removeAt(idx);
      total -= issue.price;
    }
    notifyListeners();
  }

  bool isIssueSelected(Issue issue) =>
      selIssues.any((item) => item.name == issue.name);
}

// ═══════════════════════════════════════════
//  APP ROOT
// ═══════════════════════════════════════════
class FixNGoApp extends StatelessWidget {
  const FixNGoApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Fix-N-Go',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(scaffoldBackgroundColor: AppColors.dark2),
        home: const PhoneShell(),
      );
}

class PhoneShell extends StatelessWidget {
  const PhoneShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.dark2,
      body: LayoutBuilder(builder: (ctx, constraints) {
        if (constraints.maxWidth < 600) {
          return const SafeArea(child: AppNavigator(showFakeStatusBar: false));
        }

        const ratio = 390.0 / 844.0;
        double fw = constraints.maxWidth * 0.9;
        double fh = fw / ratio;
        if (fh > constraints.maxHeight * 0.95) {
          fh = constraints.maxHeight * 0.95;
          fw = fh * ratio;
        }

        return Center(
          child: Container(
            width: fw,
            height: fh,
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.16),
                  blurRadius: 32,
                  offset: const Offset(0, 18),
                ),
              ],
            ),
            child: const AppNavigator(showFakeStatusBar: true),
          ),
        );
      }),
    );
  }
}

class AppNavigator extends StatefulWidget {
  final bool showFakeStatusBar;

  const AppNavigator({super.key, this.showFakeStatusBar = true});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  final _state = AppState();

  @override
  void initState() {
    super.initState();
    _state.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (widget.showFakeStatusBar) const StatusBar(),
        Expanded(
          child: AnimatedBuilder(
            animation: _state,
            builder: (context, child) => switch (_state.currentScreen) {
              'login' => ScreenLogin(state: _state),
              'register' => ScreenRegister(state: _state),
              's1' => Screen1Home(state: _state),
              's2' => Screen2BrandModel(state: _state),
              's3' => Screen3Issues(state: _state),
              's4' => Screen4Finding(state: _state),
              's5' => Screen5Confirmed(state: _state),
              'orders' => ScreenOrders(state: _state),
              'order_detail' => ScreenOrderDetail(state: _state),
              'profile' => ScreenProfile(state: _state),
              'edit_profile' => ScreenEditProfile(state: _state),
              _ => ScreenLogin(state: _state),
            },
          ),
        ),
      ],
    );
  }
}

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  late Timer _timer;
  String _time = '';

  @override
  void initState() {
    super.initState();
    _time = _formattedTime();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) {
      setState(() {
        _time = _formattedTime();
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formattedTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Fix-N-Go', style: AppFonts.body(fontSize: 13, fontWeight: FontWeight.w700)),
          Row(children: [Text(_time, style: AppFonts.body(fontSize: 13)), const SizedBox(width: 12), const Icon(Icons.signal_cellular_4_bar, size: 16), const SizedBox(width: 6), const Icon(Icons.battery_full, size: 16)]),
        ],
      ),
    );
  }
}

class ScreenLogin extends StatefulWidget {
  final AppState state;

  const ScreenLogin({super.key, required this.state});

  @override
  State<ScreenLogin> createState() => _ScreenLoginState();
}

class _ScreenLoginState extends State<ScreenLogin> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Welcome back', style: AppFonts.display(fontSize: 28, color: AppColors.black)),
          const SizedBox(height: 8),
          Text('Login to book your repair service fast.', style: AppFonts.body(color: AppColors.muted)),
          const SizedBox(height: 24),
          _InputField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _InputField(label: 'Password', controller: _passwordController, obscureText: true),
          if (state.errorMessage != null) ...[
            const SizedBox(height: 12),
            Text(state.errorMessage!, style: AppFonts.body(color: AppColors.red)),
          ],
          const Spacer(),
          _PrimaryButton(
            label: state.isLoading ? 'Please wait...' : 'Login',
            onPressed: state.isLoading
                ? null
                : () async {
                    final ok = await state.login(
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (!ok) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage ?? 'Login failed')),
                      );
                    }
                  },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => state.go('register'),
            child: Text('Create an account', style: AppFonts.body(color: AppColors.blue)),
          ),
          Text('API: ${ApiConfig.baseUrl}', style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
        ],
      ),
    );
  }
}

class ScreenRegister extends StatefulWidget {
  final AppState state;

  const ScreenRegister({super.key, required this.state});

  @override
  State<ScreenRegister> createState() => _ScreenRegisterState();
}

class _ScreenRegisterState extends State<ScreenRegister> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Register', style: AppFonts.display(fontSize: 28, color: AppColors.black)),
          const SizedBox(height: 8),
          Text('Create your Fix-N-Go account.', style: AppFonts.body(color: AppColors.muted)),
          const SizedBox(height: 24),
          _InputField(label: 'Name', controller: _nameController),
          const SizedBox(height: 16),
          _InputField(label: 'Email', controller: _emailController, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _InputField(label: 'Password', controller: _passwordController, obscureText: true),
          const Spacer(),
          _PrimaryButton(
            label: state.isLoading ? 'Please wait...' : 'Create account',
            onPressed: state.isLoading
                ? null
                : () async {
                    final ok = await state.register(
                      _nameController.text.trim(),
                      _emailController.text.trim(),
                      _passwordController.text,
                    );
                    if (!ok) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(state.errorMessage ?? 'Registration failed')),
                      );
                    }
                  },
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => state.go('login'),
            child: Text('Back to Login', style: AppFonts.body(color: AppColors.blue)),
          ),
        ],
      ),
    );
  }
}

class Screen1Home extends StatelessWidget {
  final AppState state;

  const Screen1Home({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Hello, ${state.userName.split(' ').first}', style: AppFonts.display(fontSize: 28, color: AppColors.black)),
          const SizedBox(height: 8),
          Text('Ready for your next repair?', style: AppFonts.body(color: AppColors.muted)),
          const SizedBox(height: 24),
          _FeatureCard(
            title: 'Book a Service',
            subtitle: 'Select brand, model, and issues',
            icon: Icons.build,
            onPressed: () => state.go('s2'),
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'My Orders',
            subtitle: 'Track service status and history',
            icon: Icons.receipt_long,
            onPressed: () => state.go('orders'),
          ),
          const SizedBox(height: 16),
          _FeatureCard(
            title: 'Profile',
            subtitle: 'View account details and settings',
            icon: Icons.person,
            onPressed: () => state.go('profile'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class Screen2BrandModel extends StatelessWidget {
  final AppState state;

  const Screen2BrandModel({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final brandList = state.brands.isNotEmpty ? state.brands : [const Brand(name: 'Samsung', emoji: '📱', models: ['Galaxy S25'])];
    final selectedBrand = brandList.firstWhere(
      (brand) => brand.name == state.selBrand,
      orElse: () => brandList.first,
    );

    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Choose a brand', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: brandList.map((brand) {
              final selected = state.selBrand == brand.name;
              return ChoiceChip(
                selected: selected,
                label: Text('${brand.emoji} ${brand.name}'),
                onSelected: (_) => state.selectBrand(brand.name),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Select a model', style: AppFonts.display(fontSize: 20, color: AppColors.black)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: selectedBrand.models.map((model) {
              final selected = state.selModel == model;
              return FilterChip(
                selected: selected,
                label: Text(model),
                onSelected: (_) => state.selectModel(model),
              );
            }).toList(),
          ),
          const Spacer(),
          _PrimaryButton(
            label: 'Next',
            onPressed: state.selModel.isNotEmpty ? () => state.go('s3') : null,
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => state.go('s1'), child: Text('Back to Home', style: AppFonts.body(color: AppColors.blue))),
        ],
      ),
    );
  }
}

class Screen3Issues extends StatelessWidget {
  final AppState state;

  const Screen3Issues({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Select issues', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: state.catalogIssues.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final issue = state.catalogIssues[index];
                final selected = state.isIssueSelected(issue);
                return ListTile(
                  tileColor: selected ? AppColors.blue.withValues(alpha: 0.12) : AppColors.white,
                  title: Text(issue.name, style: AppFonts.body(fontWeight: FontWeight.w700)),
                  subtitle: Text(issue.description, style: AppFonts.body(color: AppColors.muted)),
                  trailing: Text('₹${issue.price}', style: AppFonts.body(fontWeight: FontWeight.w700)),
                  onTap: () => state.toggleIssue(issue),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Text('Total estimate: ₹${state.total}', style: AppFonts.display(fontSize: 18, color: AppColors.black)),
          const SizedBox(height: 16),
          _PrimaryButton(label: 'Find Technician', onPressed: state.selIssues.isNotEmpty ? () => state.go('s4') : null),
          const SizedBox(height: 12),
          TextButton(onPressed: () => state.go('s2'), child: Text('Back', style: AppFonts.body(color: AppColors.blue))),
        ],
      ),
    );
  }
}

class Screen4Finding extends StatefulWidget {
  final AppState state;

  const Screen4Finding({super.key, required this.state});

  @override
  State<Screen4Finding> createState() => _Screen4FindingState();
}

class _Screen4FindingState extends State<Screen4Finding> {
  double _progress = 0.0;
  Timer? _timer;
  String? _error;

  @override
  void initState() {
    super.initState();
    _startFinding();
  }

  Future<void> _startFinding() async {
    try {
      await widget.state.loadTechnicians();
    } catch (e) {
      if (mounted) setState(() => _error = e.toString());
    }
    _timer = Timer.periodic(const Duration(milliseconds: 400), (timer) {
      if (!mounted) return;
      setState(() {
        _progress += 0.12;
        if (_progress >= 1.0) {
          _progress = 1.0;
          timer.cancel();
          _finishBooking();
        }
      });
    });
  }

  Future<void> _finishBooking() async {
    try {
      await widget.state.submitOrder();
      if (mounted) widget.state.go('s5');
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Booking failed: $e')));
        widget.state.go('s3');
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 24),
          Text('Finding your technician', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          Text(
            _error ?? 'We are assigning a trusted professional to your booking.',
            style: AppFonts.body(color: _error != null ? AppColors.red : AppColors.muted),
          ),
          const SizedBox(height: 32),
          LinearProgressIndicator(value: _progress, minHeight: 12, color: AppColors.blue, backgroundColor: AppColors.border),
          const SizedBox(height: 12),
          Text('${(_progress * 100).ceil()}% complete', style: AppFonts.body(color: AppColors.black)),
          const Spacer(),
          _PrimaryButton(label: 'Cancel', onPressed: () => widget.state.go('s3')),
        ],
      ),
    );
  }
}

class Screen5Confirmed extends StatelessWidget {
  final AppState state;

  const Screen5Confirmed({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final techList = state.technicians.isNotEmpty
        ? state.technicians
        : [const Technician(name: 'Technician', emoji: '🛠️', rating: '4.8', experience: '', eta: '15 min', distance: '', jobs: 0)];
    final technician = techList.firstWhere(
      (tech) => tech.name == state.pickedTechName,
      orElse: () => techList.first,
    );

    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Booking confirmed', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          Text('Technician ${technician.name} will arrive within ${technician.eta}.', style: AppFonts.body(color: AppColors.muted)),
          const SizedBox(height: 24),
          _InfoTile(title: 'Estimated cost', value: '₹${state.total}'),
          const SizedBox(height: 12),
          _InfoTile(title: 'Technician', value: '${technician.emoji} ${technician.name}'),
          const SizedBox(height: 12),
          _InfoTile(title: 'Contact', value: state.userPhone),
          const Spacer(),
          _PrimaryButton(label: 'View Orders', onPressed: () => state.go('orders')),
          const SizedBox(height: 12),
          TextButton(onPressed: () => state.go('s1'), child: Text('Go Home', style: AppFonts.body(color: AppColors.blue))),
        ],
      ),
    );
  }
}

class ScreenOrders extends StatelessWidget {
  final AppState state;

  const ScreenOrders({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('My Orders', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          Expanded(
            child: state.orders.isEmpty
                ? Center(child: Text('No orders yet. Book your first repair!', style: AppFonts.body(color: AppColors.muted)))
                : ListView.separated(
              itemCount: state.orders.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.orders[index];
                return InkWell(
                  onTap: () {
                    state.selectedOrderId = order.rawId;
                    state.go('order_detail');
                  },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order.id, style: AppFonts.body(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text('${order.brand} ${order.model}', style: AppFonts.body(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text(order.issues.join(', '), style: AppFonts.body(color: AppColors.muted)),
                        const SizedBox(height: 6),
                        Text('₹${order.total} • ${order.status}', style: AppFonts.body(fontWeight: FontWeight.w700, color: AppColors.blue)),
                        const SizedBox(height: 4),
                        Text('Tap for tracking', style: AppFonts.body(fontSize: 11, color: AppColors.muted)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          _PrimaryButton(label: 'Back to Home', onPressed: () => state.go('s1')),
        ],
      ),
    );
  }
}

class ScreenProfile extends StatelessWidget {
  final AppState state;

  const ScreenProfile({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Profile', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          _InfoTile(title: 'Name', value: state.userName),
          const SizedBox(height: 12),
          _InfoTile(title: 'Email', value: state.userEmail),
          const SizedBox(height: 12),
          _InfoTile(title: 'Phone', value: state.userPhone),
          const SizedBox(height: 12),
          _InfoTile(title: 'Location', value: state.userLocation),
          const Spacer(),
          _PrimaryButton(label: 'Edit profile', onPressed: () => state.go('edit_profile')),
          const SizedBox(height: 12),
          _PrimaryButton(label: 'Logout', onPressed: () => state.logout()),
          const SizedBox(height: 12),
          TextButton(onPressed: () => state.go('s1'), child: Text('Back to Home', style: AppFonts.body(color: AppColors.blue))),
        ],
      ),
    );
  }
}

class ScreenEditProfile extends StatefulWidget {
  final AppState state;

  const ScreenEditProfile({super.key, required this.state});

  @override
  State<ScreenEditProfile> createState() => _ScreenEditProfileState();
}

class _ScreenEditProfileState extends State<ScreenEditProfile> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late final TextEditingController _city;
  late final TextEditingController _pincode;

  @override
  void initState() {
    super.initState();
    final loc = widget.state.userLocation.split(',');
    _name = TextEditingController(text: widget.state.userName);
    _phone = TextEditingController(text: widget.state.userPhone);
    _address = TextEditingController(text: loc.isNotEmpty ? loc.first.trim() : '');
    _city = TextEditingController(text: loc.length > 1 ? loc.sublist(1).join(',').trim() : 'Hyderabad');
    _pincode = TextEditingController(text: '500084');
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    _city.dispose();
    _pincode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Edit profile', style: AppFonts.display(fontSize: 24, color: AppColors.black)),
          const SizedBox(height: 16),
          _InputField(label: 'Name', controller: _name),
          const SizedBox(height: 12),
          _InputField(label: 'Phone', controller: _phone, keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _InputField(label: 'Address', controller: _address),
          const SizedBox(height: 12),
          _InputField(label: 'City', controller: _city),
          const SizedBox(height: 12),
          _InputField(label: 'Pincode', controller: _pincode, keyboardType: TextInputType.number),
          const Spacer(),
          _PrimaryButton(
            label: 'Save',
            onPressed: () async {
              final ok = await state.saveProfile(
                name: _name.text.trim(),
                phone: _phone.text.trim(),
                address: _address.text.trim(),
                city: _city.text.trim(),
                pincode: _pincode.text.trim(),
              );
              if (!context.mounted) return;
              if (ok) {
                state.go('profile');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.errorMessage ?? 'Save failed')),
                );
              }
            },
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: () => state.go('profile'), child: Text('Cancel', style: AppFonts.body(color: AppColors.blue))),
        ],
      ),
    );
  }
}

class ScreenOrderDetail extends StatefulWidget {
  final AppState state;

  const ScreenOrderDetail({super.key, required this.state});

  @override
  State<ScreenOrderDetail> createState() => _ScreenOrderDetailState();
}

class _ScreenOrderDetailState extends State<ScreenOrderDetail> {
  Map<String, dynamic>? _detail;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = widget.state.selectedOrderId;
    if (id == null) return;
    try {
      final data = await widget.state.api.getOrderById(id);
      if (mounted) setState(() { _detail = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Container(color: AppColors.off2, child: const Center(child: CircularProgressIndicator()));
    }
    final detail = _detail;
    if (detail == null) {
      return Container(
        color: AppColors.off2,
        padding: const EdgeInsets.all(20),
        child: Center(child: Text('Order not found', style: AppFonts.body())),
      );
    }
    final order = Order.fromJson(detail);
    final history = order.statusHistory;

    return Container(
      color: AppColors.off2,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text('Order ${order.id}', style: AppFonts.display(fontSize: 22, color: AppColors.black)),
          const SizedBox(height: 8),
          Text('${order.brand} ${order.model}', style: AppFonts.body(fontWeight: FontWeight.w700)),
          Text('Status: ${order.status}', style: AppFonts.body(color: AppColors.blue, fontWeight: FontWeight.w700)),
          Text('Technician: ${order.techName}', style: AppFonts.body(color: AppColors.muted)),
          const SizedBox(height: 20),
          Text('Tracking', style: AppFonts.display(fontSize: 18, color: AppColors.black)),
          const SizedBox(height: 12),
          Expanded(
            child: history.isEmpty
                ? Center(child: Text('No tracking updates yet', style: AppFonts.body(color: AppColors.muted)))
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final step = history[index];
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(step['status']?.toString() ?? '', style: AppFonts.body(fontWeight: FontWeight.w700)),
                            if (step['note'] != null)
                              Text(step['note'].toString(), style: AppFonts.body(color: AppColors.muted)),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _PrimaryButton(label: 'Back to orders', onPressed: () => widget.state.go('orders')),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType? keyboardType;

  const _InputField({
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        filled: true,
        fillColor: AppColors.white,
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.blue,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(label, style: AppFonts.body(color: AppColors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onPressed;

  const _FeatureCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.all(14),
              child: Icon(icon, color: AppColors.blue, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppFonts.body(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppFonts.body(color: AppColors.muted)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 18, color: AppColors.muted),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;

  const _InfoTile({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppFonts.label(context: context)),
          const SizedBox(height: 8),
          Text(value, style: AppFonts.body(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}
