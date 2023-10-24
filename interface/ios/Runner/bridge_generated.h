#include <stdbool.h>
#include <stdint.h>
#include <stdlib.h>
typedef struct _Dart_Handle* Dart_Handle;

#define FRAME_SIZE 960

typedef struct DartCObject DartCObject;

typedef int64_t DartPort;

typedef bool (*DartPostCObjectFnType)(DartPort port_id, void *message);

typedef struct wire_uint_8_list {
  uint8_t *ptr;
  int32_t len;
} wire_uint_8_list;

typedef struct DartCObject *WireSyncReturn;

void store_dart_post_cobject(DartPostCObjectFnType ptr);

Dart_Handle get_dart_object(uintptr_t ptr);

void drop_dart_object(uintptr_t ptr);

uintptr_t new_dart_opaque(Dart_Handle handle);

intptr_t init_frb_dart_api_dl(void *obj);

void wire_create_log_stream(int64_t port_);

void wire_create_action_stream(int64_t port_);

void wire_start_voice(int64_t port_,
                      struct wire_uint_8_list *client_id,
                      struct wire_uint_8_list *verification_key,
                      struct wire_uint_8_list *encryption_key,
                      struct wire_uint_8_list *address);

void wire_test_voice(int64_t port_, struct wire_uint_8_list *device);

void wire_stop(int64_t port_);

void wire_set_muted(int64_t port_, bool muted);

void wire_set_deafen(int64_t port_, bool deafened);

void wire_is_muted(int64_t port_);

void wire_is_deafened(int64_t port_);

void wire_set_amplitude_logging(int64_t port_, bool amplitude_logging);

void wire_is_amplitude_logging(int64_t port_);

void wire_set_talking_amplitude(int64_t port_, float amplitude);

void wire_get_talking_amplitude(int64_t port_);

void wire_set_silent_mute(int64_t port_, bool silent_mute);

void wire_create_amplitude_stream(int64_t port_);

void wire_delete_amplitude_stream(int64_t port_);

void wire_list_input_devices(int64_t port_);

void wire_get_default_id(int64_t port_);

void wire_list_output_devices(int64_t port_);

void wire_set_input_device(int64_t port_, struct wire_uint_8_list *id);

void wire_set_output_device(int64_t port_, struct wire_uint_8_list *id);

struct wire_uint_8_list *new_uint_8_list_0(int32_t len);

void free_WireSyncReturn(WireSyncReturn ptr);

static int64_t dummy_method_to_enforce_bundling(void) {
    int64_t dummy_var = 0;
    dummy_var ^= ((int64_t) (void*) wire_create_log_stream);
    dummy_var ^= ((int64_t) (void*) wire_create_action_stream);
    dummy_var ^= ((int64_t) (void*) wire_start_voice);
    dummy_var ^= ((int64_t) (void*) wire_test_voice);
    dummy_var ^= ((int64_t) (void*) wire_stop);
    dummy_var ^= ((int64_t) (void*) wire_set_muted);
    dummy_var ^= ((int64_t) (void*) wire_set_deafen);
    dummy_var ^= ((int64_t) (void*) wire_is_muted);
    dummy_var ^= ((int64_t) (void*) wire_is_deafened);
    dummy_var ^= ((int64_t) (void*) wire_set_amplitude_logging);
    dummy_var ^= ((int64_t) (void*) wire_is_amplitude_logging);
    dummy_var ^= ((int64_t) (void*) wire_set_talking_amplitude);
    dummy_var ^= ((int64_t) (void*) wire_get_talking_amplitude);
    dummy_var ^= ((int64_t) (void*) wire_set_silent_mute);
    dummy_var ^= ((int64_t) (void*) wire_create_amplitude_stream);
    dummy_var ^= ((int64_t) (void*) wire_delete_amplitude_stream);
    dummy_var ^= ((int64_t) (void*) wire_list_input_devices);
    dummy_var ^= ((int64_t) (void*) wire_get_default_id);
    dummy_var ^= ((int64_t) (void*) wire_list_output_devices);
    dummy_var ^= ((int64_t) (void*) wire_set_input_device);
    dummy_var ^= ((int64_t) (void*) wire_set_output_device);
    dummy_var ^= ((int64_t) (void*) new_uint_8_list_0);
    dummy_var ^= ((int64_t) (void*) free_WireSyncReturn);
    dummy_var ^= ((int64_t) (void*) store_dart_post_cobject);
    dummy_var ^= ((int64_t) (void*) get_dart_object);
    dummy_var ^= ((int64_t) (void*) drop_dart_object);
    dummy_var ^= ((int64_t) (void*) new_dart_opaque);
    return dummy_var;
}
