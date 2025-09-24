import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/home/home_page.dart';
import '../presentation/pages/products/products_page.dart';
import '../presentation/pages/products/product_form_page.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (c, s) => const HomePage()),
    GoRoute(path: '/products', builder: (c, s) => const ProductsPage()),
    GoRoute(path: '/products/new', builder: (c, s) => const ProductFormPage()),
  ],
);
