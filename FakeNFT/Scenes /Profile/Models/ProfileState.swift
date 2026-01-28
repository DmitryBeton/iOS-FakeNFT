enum ProfileState {
    case initial, loading, failed(ErrorModel), data(ProfileUI)
}
