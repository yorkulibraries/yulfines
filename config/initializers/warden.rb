Rails.application.reloader.to_prepare do
  Warden::Strategies.add(:ppy_auth, Warden::PpyAuthStrategy)
  Warden::Strategies.add(:barcode_auth, Warden::BarcodeAuthStrategy)
end