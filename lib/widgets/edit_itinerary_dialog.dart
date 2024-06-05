import 'package:absence_watch/common/theme.dart';
import 'package:country_pickers/countries.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../common/util.dart';
import '../models/itinerary.dart';
import '../models/purposes.dart';
import 'package:flutter/cupertino.dart';

enum DateType {
  departure,
  arrival,
}

class EditItineraryDialog extends StatefulWidget {
  final Itinerary? initialItinerary;
  final String? userId;
  final List<DateTime>? blackoutDates;
  final DateTime? lastArrivalDate;
  final DateTime? nextDepartureDate;
  final Country? lastArrivalCountry;

  const EditItineraryDialog({
    super.key,
    this.initialItinerary,
    this.userId,
    this.blackoutDates,
    this.lastArrivalDate,
    this.nextDepartureDate,
    this.lastArrivalCountry,
  });

  @override
  _EditItineraryDialogState createState() => _EditItineraryDialogState();
}

class _EditItineraryDialogState extends State<EditItineraryDialog> {
  final _formKey = GlobalKey<FormState>();
  Country? departureCountry;
  DateTime? departureDate;
  Country? arrivalCountry;
  DateTime? arrivalDate;
  String? purpose;
  bool isSameDayArrival = true;

  bool get isEditMode => widget.initialItinerary != null;

  late TextEditingController _departureDateController;
  late TextEditingController _arrivalDateController;

  @override
  void initState() {
    super.initState();

    if (widget.initialItinerary != null) {
      // If an initial itinerary is provided, populate the fields with its data
      departureCountry = widget.initialItinerary!.departureCountry;
      departureDate = widget.initialItinerary!.departureDate;
      arrivalCountry = widget.initialItinerary!.arrivalCountry;
      arrivalDate = widget.initialItinerary!.arrivalDate;
      purpose = widget.initialItinerary!.purpose;
      isSameDayArrival = departureDate == arrivalDate;
    } else {
      // Initialize with default values
      departureCountry = widget.lastArrivalCountry;
      departureDate = null;
      arrivalCountry = null;
      arrivalDate = null;
      purpose = null;
      isSameDayArrival = true;
    }

    _departureDateController = TextEditingController(
        text: departureDate == null ? '' : formatDate(departureDate));

    _arrivalDateController = TextEditingController(
        text: arrivalDate == null ? '' : formatDate(arrivalDate));

    // if (isEditMode) {
    //   final initialItinerary = widget.initialItinerary!;
    //   departureCountry = initialItinerary.departureCountry;
    //   departureDate = initialItinerary.departureDate;
    //   arrivalCountry = initialItinerary.arrivalCountry;
    //   arrivalDate = initialItinerary.arrivalDate;
    //   purpose = initialItinerary.purpose;
    //   isSameDayArrival = departureDate == arrivalDate;
    // } else {
    //   departureCountry = widget.lastArrivalCountry;
    // }
  }

  @override
  void dispose() {
    _departureDateController.dispose();
    _arrivalDateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, DateTime initialDate,
      DateTime? minDate, DateTime? maxDate, DateType dateType) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: SfDateRangePicker(
            selectionMode: DateRangePickerSelectionMode.single,
            initialSelectedDate: initialDate,
            minDate: minDate,
            maxDate: maxDate,
            showActionButtons: true,
            onSubmit: (Object? value) {
              if (value is DateTime) {
                setState(() {
                  if (dateType == DateType.departure) {
                    departureDate = value;
                    _departureDateController.text = formatDate(departureDate);
                  } else {
                    arrivalDate = value;
                    _arrivalDateController.text = formatDate(arrivalDate);
                  }
                });
                Navigator.pop(context);
              }
            },
            onCancel: () => Navigator.pop(context),
            monthViewSettings: DateRangePickerMonthViewSettings(
              blackoutDates: widget.blackoutDates,
            ),
          ),
        );
      },
    );
  }

  bool _validateForm() {
    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return false;
    }

    form.save();

    if (departureCountry == arrivalCountry) {
      _showSnackBar('Departure and arrival countries should be different');
      return false;
    }

    if (isSameDayArrival) {
      arrivalDate = departureDate;
    }

    if (_isInvalidDate(
            departureDate, 'Departure date cannot be in the future') ||
        _isInvalidDate(arrivalDate, 'Arrival date cannot be in the future') ||
        _isInvalidDateOrder(departureDate, arrivalDate,
            'Arrival date should be on or after the departure date')) {
      return false;
    }

    return true;
  }

  bool _isInvalidDate(DateTime? date, String message) {
    if (date != null && date.isAfter(DateTime.now())) {
      _showSnackBar(message);
      return true;
    }
    return false;
  }

  bool _isInvalidDateOrder(
      DateTime? startDate, DateTime? endDate, String message) {
    if (startDate != null && endDate != null && endDate.isBefore(startDate)) {
      _showSnackBar(message);
      return true;
    }
    return false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _buildInputDecoration(
      {required String label, Icon? suffixIcon}) {
    return InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
        ),
        floatingLabelBehavior: FloatingLabelBehavior.never,
        suffixIcon: suffixIcon,
        labelStyle: const TextStyle(
          fontSize: 14.0,
        ));
  }

  Widget _buildFormField(
      {required String label,
      required Widget formFieldWidget,
      Widget? suffixWidget}) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 4.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label),
          const SizedBox(
            height: 8,
          ),
          formFieldWidget,
          if (suffixWidget != null) ...[suffixWidget]
        ],
      ),
    );
  }

  Widget _buildCountryPicker(
      {required String label,
      Country? initialValue,
      required Function(String?) onChanged,
      Widget? suffixWidget,
      List<String>? favoriteCountryCodes}) {
    return _buildFormField(
      label: label,
      formFieldWidget: DropdownButtonFormField<String>(
        decoration: _buildInputDecoration(label: label),
        value: initialValue?.isoCode,
        items: [
          if (favoriteCountryCodes!.isNotEmpty)
            ..._buildFavoriteCountryItems(favoriteCountryCodes),
          const DropdownMenuItem<String>(
            value: '', // Empty value for separator
            enabled: false,
            child: Divider(),
          ),
          ...countryList.map<DropdownMenuItem<String>>((Country country) {
            return DropdownMenuItem<String>(
              value: country.isoCode,
              child: Row(
                children: <Widget>[
                  CountryPickerUtils.getDefaultFlagImage(country),
                  const SizedBox(width: 8.0),
                  SizedBox(
                    width: 150,
                    child: Text(
                      country.name,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
        onChanged: (String? newValue) {
          if (newValue != null) {
            if (newValue.startsWith("fav-")) {
              newValue = newValue.substring(4); // Remove "fav-" prefix
            }
            onChanged(newValue); // Trigger the original onChanged
          }
        },
        validator: (value) => value == null ? 'Please select a country' : null,
      ),
      suffixWidget: suffixWidget,
    );
  }

  List<DropdownMenuItem<String>> _buildFavoriteCountryItems(
      List<String> favoriteCountryCodes) {
    return favoriteCountryCodes.map((countryCode) {
      Country country = countryList.firstWhere(
        (c) => c.isoCode == countryCode,
      );
      return DropdownMenuItem<String>(
        value: "fav-${country.isoCode}",
        child: Row(
          children: <Widget>[
            CountryPickerUtils.getDefaultFlagImage(country),
            const SizedBox(width: 8.0),
            Text(country.name),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildDateField(
      {required String label,
      required TextEditingController controller,
      DateTime? date,
      required Function() onTap,
      Widget? suffixWidget}) {
    return _buildFormField(
      label: label,
      formFieldWidget: TextFormField(
        decoration: _buildInputDecoration(
          label: label,
          suffixIcon: Icon(Icons.calendar_month_rounded),
        ),
        controller: controller,
        readOnly: true,
        onTap: onTap,
        validator: (value) => value == null ? 'Please select a date' : null,
      ),
      suffixWidget: suffixWidget,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildCountryPicker(
              label: "Origin Country",
              initialValue: departureCountry,
              onChanged: (String? selectedCountryIsoCode) => {
                setState(() {
                  departureCountry = CountryPickerUtils.getCountryByIsoCode(
                      selectedCountryIsoCode!);
                })
              },
              suffixWidget: null,
              favoriteCountryCodes: ["GB"],
            ),
            _buildCountryPicker(
              label: "Destination Country",
              initialValue: arrivalCountry,
              onChanged: (String? selectedCountryIsoCode) => {
                setState(() {
                  arrivalCountry = CountryPickerUtils.getCountryByIsoCode(
                      selectedCountryIsoCode!);
                })
              },
              suffixWidget: null,
              favoriteCountryCodes: ["GB"],
            ),
            _buildDateField(
              label: 'Departure Date',
              controller: _departureDateController,
              date: departureDate,
              onTap: () => _selectDate(
                context,
                departureDate ?? widget.lastArrivalDate ?? DateTime.now(),
                null,
                DateTime.now(),
                DateType.departure,
              ),
              suffixWidget: Row(
                children: <Widget>[
                  Checkbox(
                    value: isSameDayArrival,
                    onChanged: (value) {
                      setState(() {
                        isSameDayArrival = value!;
                      });
                    },
                    visualDensity: VisualDensity.compact,
                  ),
                  const Text(
                    'Arrive on the same day',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ],
              ),
            ),
            if (!isSameDayArrival)
              _buildDateField(
                label: 'Arrival Date',
                controller: _arrivalDateController,
                date: arrivalDate,
                onTap: () => _selectDate(
                  context,
                  arrivalDate ?? departureDate ?? DateTime.now(),
                  departureDate,
                  DateTime.now(),
                  DateType.arrival,
                ),
              ),
            if (arrivalCountry?.isoCode != "GB")
              _buildFormField(
                label: 'Purpose of Travel',
                formFieldWidget: DropdownButtonFormField<String>(
                  decoration: _buildInputDecoration(label: 'Purpose of Travel'),
                  value: purpose,
                  items: purposes.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      purpose = newValue;
                    });
                  },
                  validator: (value) => value == null
                      ? 'Please select the purpose of travel'
                      : null,
                ),
              ),
            Container(
              padding: const EdgeInsets.only(
                top: 24.0,
              ),
              child: SizedBox(
                height: 55.0,
                width: double.infinity,
                child: FilledButton(
                  style: primaryButtonStyle,
                  onPressed: () {
                    if (_validateForm()) {
                      Navigator.pop(
                          context,
                          Itinerary(
                            userId: widget.userId!,
                            departureCountry: departureCountry!,
                            departureDate: departureDate!,
                            arrivalCountry: arrivalCountry!,
                            arrivalDate: arrivalDate!,
                            purpose: purpose,
                          ));
                    }
                  },
                  child: Text(widget.initialItinerary != null
                      ? 'Update Itinerary'
                      : 'Add Itinerary'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
