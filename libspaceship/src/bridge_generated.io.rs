use super::*;
// Section: wire functions

#[no_mangle]
pub extern "C" fn wire_create_log_stream(port_: i64) {
    wire_create_log_stream_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_create_action_stream(port_: i64) {
    wire_create_action_stream_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_start_voice(
    port_: i64,
    client_id: *mut wire_uint_8_list,
    verification_key: *mut wire_uint_8_list,
    encryption_key: *mut wire_uint_8_list,
    address: *mut wire_uint_8_list,
) {
    wire_start_voice_impl(port_, client_id, verification_key, encryption_key, address)
}

#[no_mangle]
pub extern "C" fn wire_test_voice(port_: i64, device: *mut wire_uint_8_list) {
    wire_test_voice_impl(port_, device)
}

#[no_mangle]
pub extern "C" fn wire_stop(port_: i64) {
    wire_stop_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_muted(port_: i64, muted: bool) {
    wire_set_muted_impl(port_, muted)
}

#[no_mangle]
pub extern "C" fn wire_set_deafen(port_: i64, deafened: bool) {
    wire_set_deafen_impl(port_, deafened)
}

#[no_mangle]
pub extern "C" fn wire_is_muted(port_: i64) {
    wire_is_muted_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_is_deafened(port_: i64) {
    wire_is_deafened_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_amplitude_logging(port_: i64, amplitude_logging: bool) {
    wire_set_amplitude_logging_impl(port_, amplitude_logging)
}

#[no_mangle]
pub extern "C" fn wire_is_amplitude_logging(port_: i64) {
    wire_is_amplitude_logging_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_talking_amplitude(port_: i64, amplitude: f32) {
    wire_set_talking_amplitude_impl(port_, amplitude)
}

#[no_mangle]
pub extern "C" fn wire_get_talking_amplitude(port_: i64) {
    wire_get_talking_amplitude_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_silent_mute(port_: i64, silent_mute: bool) {
    wire_set_silent_mute_impl(port_, silent_mute)
}

#[no_mangle]
pub extern "C" fn wire_create_amplitude_stream(port_: i64) {
    wire_create_amplitude_stream_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_delete_amplitude_stream(port_: i64) {
    wire_delete_amplitude_stream_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_list_input_devices(port_: i64) {
    wire_list_input_devices_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_get_default_id(port_: i64) {
    wire_get_default_id_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_list_output_devices(port_: i64) {
    wire_list_output_devices_impl(port_)
}

#[no_mangle]
pub extern "C" fn wire_set_input_device(port_: i64, id: *mut wire_uint_8_list) {
    wire_set_input_device_impl(port_, id)
}

#[no_mangle]
pub extern "C" fn wire_set_output_device(port_: i64, id: *mut wire_uint_8_list) {
    wire_set_output_device_impl(port_, id)
}

// Section: allocate functions

#[no_mangle]
pub extern "C" fn new_uint_8_list_0(len: i32) -> *mut wire_uint_8_list {
    let ans = wire_uint_8_list {
        ptr: support::new_leak_vec_ptr(Default::default(), len),
        len,
    };
    support::new_leak_box_ptr(ans)
}

// Section: related functions

// Section: impl Wire2Api

impl Wire2Api<String> for *mut wire_uint_8_list {
    fn wire2api(self) -> String {
        let vec: Vec<u8> = self.wire2api();
        String::from_utf8_lossy(&vec).into_owned()
    }
}

impl Wire2Api<Vec<u8>> for *mut wire_uint_8_list {
    fn wire2api(self) -> Vec<u8> {
        unsafe {
            let wrap = support::box_from_leak_ptr(self);
            support::vec_from_leak_ptr(wrap.ptr, wrap.len)
        }
    }
}
// Section: wire structs

#[repr(C)]
#[derive(Clone)]
pub struct wire_uint_8_list {
    ptr: *mut u8,
    len: i32,
}

// Section: impl NewWithNullPtr

pub trait NewWithNullPtr {
    fn new_with_null_ptr() -> Self;
}

impl<T> NewWithNullPtr for *mut T {
    fn new_with_null_ptr() -> Self {
        std::ptr::null_mut()
    }
}

// Section: sync execution mode utility

#[no_mangle]
pub extern "C" fn free_WireSyncReturn(ptr: support::WireSyncReturn) {
    unsafe {
        let _ = support::box_from_leak_ptr(ptr);
    };
}
