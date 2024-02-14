import 'package:flutter/material.dart';
import 'package:flutter_grocery/data/model/response/base/api_response.dart';
import 'package:flutter_grocery/data/model/response/category_model.dart';
import 'package:flutter_grocery/data/model/response/product_model.dart';
import 'package:flutter_grocery/data/repository/product_repo.dart';
import 'package:flutter_grocery/data/repository/search_repo.dart';
import 'package:flutter_grocery/helper/api_checker.dart';
import 'package:flutter_grocery/helper/product_type.dart';

class ProductProvider extends ChangeNotifier {
  final ProductRepo productRepo;
  final SearchRepo searchRepo;

  ProductProvider({required this.productRepo, required this.searchRepo});

  ProductModel? _allProductModel;
  Product? _product;
  List<Product>? _dailyItemList;
  List<Product>? _featuredProductList;
  List<Product>? _mostViewedProductList;
  bool _isLoading = false;
  int? _popularPageSize;
  int? _latestPageSize;
  List<String> _popularOffsetList = [];
  int _quantity = 1;
  List<int>? _variationIndex;
  int? _imageSliderIndex;
  int? _cartIndex;
  int offset = 1;
  int popularOffset = 1;
  int _tabIndex = 0;

  ProductModel? get allProductModel=> _allProductModel;
  Product? get product => _product;
  int? get cartIndex => _cartIndex;
  List<Product>? get dailyItemList => _dailyItemList;
  List<Product>? get featuredProductList => _featuredProductList;
  List<Product>? get mostViewedProductList => _mostViewedProductList;
  bool get isLoading => _isLoading;
  int? get popularPageSize => _popularPageSize;
  int? get latestPageSize => _latestPageSize;
  int get quantity => _quantity;
  List<int>? get variationIndex => _variationIndex;
  int? get imageSliderIndex => _imageSliderIndex;
  int get tabIndex => _tabIndex;



  Future<void> getAllProductList(int offset, bool reload, {ProductFilterType type = ProductFilterType.latest, bool isUpdate = true}) async {
    if(reload) {
      _allProductModel = null;

      if(isUpdate) {
        notifyListeners();
      }
    }

    ApiResponse? response = await productRepo.getAllProductList(offset, type);
    if (response.response != null && response.response?.data != null && response.response?.statusCode == 200) {
      if(offset == 1){
        _allProductModel = ProductModel.fromJson(response.response?.data);
      } else {
        _allProductModel!.totalSize = ProductModel.fromJson(response.response?.data).totalSize;
        _allProductModel!.offset = ProductModel.fromJson(response.response?.data).offset;
        _allProductModel!.products!.addAll(ProductModel.fromJson(response.response?.data).products!);
      }

      notifyListeners();

    } else {
      ApiChecker.checkApi(response);
    }

  }


  Future<void> getItemList(String offset, bool reload, String? productType) async {
    if(reload || offset == '1') {
      popularOffset = 1 ;
      _popularOffsetList = [];
    }

    if (!_popularOffsetList.contains(offset)) {
      _popularOffsetList.add(offset);
      _isLoading = true;
      ApiResponse apiResponse = await productRepo.getItemList(offset, productType);
      if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
        if (reload || offset == '1' ) {
          if(productType == ProductType.dailyItem) {
            _dailyItemList = [];
          }else if(productType == ProductType.featuredItem){
            _featuredProductList = [];
          }else if(productType == ProductType.mostReviewed){
            _mostViewedProductList = [];
          }
        }

        if(productType == ProductType.dailyItem) {
          _dailyItemList!.addAll(ProductModel.fromJson(apiResponse.response!.data).products!);
        }else if(productType == ProductType.featuredItem){
          _featuredProductList!.addAll(ProductModel.fromJson(apiResponse.response!.data).products!);
        }else if(productType == ProductType.mostReviewed){
          _mostViewedProductList!.addAll(ProductModel.fromJson(apiResponse.response!.data).products!);
        }

        _popularPageSize = ProductModel.fromJson(apiResponse.response!.data).totalSize;
        _isLoading = false;

      } else {
        _isLoading = false;
        ApiChecker.checkApi(apiResponse);
      }
    } else {
      if(isLoading) {
        _isLoading = false;
      }
    }
    notifyListeners();
  }

  void setTabIndex(int index) {
    _tabIndex = index;
    notifyListeners();
  }



  Future<Product?> getProductDetails(String productID, {bool searchQuery = false}) async {
    _product = null;
    ApiResponse apiResponse = await productRepo.getProductDetails(
      productID, searchQuery,
    );

    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _product = Product.fromJson(apiResponse.response!.data);
      initData(_product!);
    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();

    return _product;

  }

  void showBottomLoader() {
    _isLoading = true;
    notifyListeners();
  }

  void setExistData(int? cartIndex) {
    _cartIndex = cartIndex;
  }

  void initData(Product product) {
    _variationIndex = [];
    _cartIndex = null;
    _quantity = 1;
    if(product.choiceOptions != null){
      for(int i=0; i < product.choiceOptions!.length; i++) {
        _variationIndex!.add(0);
      }
    }
  }


  void setQuantity(bool isIncrement) {
    if (isIncrement) {
      _quantity = _quantity + 1;
    } else {
      _quantity = _quantity - 1;
    }
    notifyListeners();
  }

  void setCartVariationIndex(int index, int i) {
    _variationIndex![index] = i;
    _quantity = 1;
    notifyListeners();
  }

  int _rating = 0;
  int get rating => _rating;

  void setRating(int rate) {
    _rating = rate;
    notifyListeners();
  }

  String? _errorText;

  String? get errorText => _errorText;

  void setErrorText(String error) {
    _errorText = error;
    notifyListeners();
  }

  void removeData() {
    _errorText = null;
    _rating = 0;
    notifyListeners();
  }

  void setImageSliderSelectedIndex(int selectedIndex) {
    _imageSliderIndex = selectedIndex;
    notifyListeners();
  }

  // Brand and category products
  List<Product> _categoryProductList = [];
  List<Product> _categoryAllProductList = [];
  bool? _hasData;

  double _maxValue = 0;

  double get maxValue => _maxValue;

  List<Product> get categoryProductList => _categoryProductList;

  List<Product> get categoryAllProductList => _categoryAllProductList;

  bool? get hasData => _hasData;

  void initCategoryProductList(String id, BuildContext context, String languageCode) async {
    _categoryProductList = [];
    _categoryAllProductList = [];
    _hasData = true;
    ApiResponse apiResponse = await productRepo.getBrandOrCategoryProductList(id, languageCode);
    if (apiResponse.response != null && apiResponse.response!.statusCode == 200) {
      _categoryProductList = [];
      _categoryAllProductList = [];
      apiResponse.response!.data.forEach((product) => _categoryProductList.add(Product.fromJson(product)));
      apiResponse.response!.data.forEach((product) => _categoryAllProductList.add(Product.fromJson(product)));
      _hasData = _categoryProductList.length > 1;
      List<Product> products = [];
      products.addAll(_categoryProductList);
      List<double> prices = [];
      for (var product in products) {
        prices.add(double.parse(product.price.toString()));
      }
      prices.sort();
      if(categoryProductList.isNotEmpty) {
        _maxValue = prices[prices.length - 1];
      }

    } else {
      ApiChecker.checkApi(apiResponse);
    }
    notifyListeners();
  }

  void sortCategoryProduct(int filterIndex) {
    if(filterIndex == 0) {
      _categoryProductList.sort((product1, product2) => product1.price!.compareTo(product2.price!));
    }else if(filterIndex == 1) {
      _categoryProductList.sort((product1, product2) => product1.price!.compareTo(product2.price!));
      Iterable iterable = _categoryProductList.reversed;
      _categoryProductList = iterable.toList() as List<Product>;
    }else if(filterIndex == 2) {
      _categoryProductList.sort((product1, product2) => product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
    }else if(filterIndex == 3) {
      _categoryProductList.sort((product1, product2) => product1.name!.toLowerCase().compareTo(product2.name!.toLowerCase()));
      Iterable iterable = _categoryProductList.reversed;
      _categoryProductList = iterable.toList() as List<Product>;
    }
    notifyListeners();
  }

  searchProduct(String query) {
    if (query.isEmpty) {
      _categoryProductList.clear();
      _categoryProductList = categoryAllProductList;
      notifyListeners();
    } else {
      _categoryProductList = [];
      for (var product in categoryAllProductList) {
        if (product.name!.toLowerCase().contains(query.toLowerCase())) {
          _categoryProductList.add(product);
        }
      }
      _hasData = _categoryProductList.length > 1;
      notifyListeners();
    }
  }

  int _filterIndex = -1;
  double _lowerValue = 0;
  double _upperValue = 0;

  int get filterIndex => _filterIndex;

  double get lowerValue => _lowerValue;

  double get upperValue => _upperValue;

  void setFilterIndex(int index) {
    _filterIndex = index;
    notifyListeners();
  }

  void setLowerAndUpperValue(double lower, double upper) {
    _lowerValue = lower;
    _upperValue = upper;
    notifyListeners();
  }


  void sortSearchList(int selectSortByIndex, List<CategoryModel> categoryList) {
    if (_upperValue > 0 && selectSortByIndex == 0) {
      _categoryProductList.clear();
      for (var product in _categoryAllProductList) {
        if (((double.parse(product.price.toString())) >= _lowerValue) && ((double.parse(product.price.toString())) <= _upperValue)) {
          _categoryProductList.add(product);
        }
      }
    } else if (_upperValue == 0 && selectSortByIndex == 0) {
      _categoryProductList .clear();
      _categoryProductList = _categoryAllProductList;
    } else if (_upperValue == 0 && selectSortByIndex == 1) {
      _categoryProductList.clear();
      _categoryProductList = _categoryAllProductList;
      _categoryProductList.sort((a, b){
        double aPrice=double.parse(a.price.toString());
        double bPrice=double.parse(b.price.toString());
        return aPrice.compareTo(bPrice);
      });
    } else if (_upperValue == 0 && selectSortByIndex == 2) {
      _categoryProductList.clear();
      _categoryProductList = _categoryAllProductList;
      _categoryProductList.sort((a, b){
        double aPrice=double.parse(a.price.toString());
        double bPrice=double.parse(b.price.toString());
        return aPrice.compareTo(bPrice);
      });
      Iterable iterable = _categoryProductList.reversed;
      _categoryProductList = iterable.toList() as List<Product>;
    }
    notifyListeners();
  }

  bool _isClear = true;

  bool get isClear => _isClear;

  void cleanSearchProduct() {
    _isClear = true;
    notifyListeners();
  }

  List<String?> _allSortBy = [];

  List<String?> get allSortBy => _allSortBy;
  int _selectSortByIndex = 0;

  int get selectSortByIndex => _selectSortByIndex;

  updateSortBy(int index) {
    _selectSortByIndex = index;
    notifyListeners();
  }

  initializeAllSortBy(BuildContext context) {
    if (_allSortBy.isEmpty) {
      _allSortBy = [];
      _allSortBy = searchRepo.getAllSortByList();
    }
    _filterIndex = -1;

  }
}
