struct Params {
    width: u32,
    height: u32,
    x_0: f32,
    y_0: f32,
    sigma_0: f32,
    p_0: f32,
    delta_t: f32
}

struct ComplexNumber {
    real: f32,
    imaginary: f32
}

@group(0) @binding(0) var<storage, read_write> buffer: array<ComplexNumber>;
@group(0) @binding(1) var<uniform> params: Params;

@vertex
fn vs_main(@builtin(vertex_index) in_vertex_index: u32) -> @builtin(position) vec4<f32> {
    let x = f32(i32(in_vertex_index & 2u) * 2 - 1);
    let y = f32(i32(in_vertex_index & 1u) * 4 - 1);
    return vec4<f32>(x, y, 0.0, 1.0);
}

@fragment
fn fs_main(@builtin(position) in: vec4<f32>) -> @location(0) vec4<f32> {
    let c = buffer[u32(in[0])+u32(in[1])*params.width];
    return vec4<f32>(
        c.real*c.real*params.sigma_0,
        c.imaginary*c.imaginary*params.sigma_0,
        f32((f32(params.width)*7.0/32.0<f32(in[0])&&f32(in[0])<f32(params.width)*8.0/32.0)&&(((f32(in[1])>f32(params.height)*18.0/32.0))|(f32(in[1])<f32(params.height)*17.0/32.0&&f32(in[1])>f32(params.height)*15.0/32.0)|(f32(in[1])<f32(params.height)*14.0/32.0))),
        1.0
    );
}

@compute
@workgroup_size(1)
fn init(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let x = f32(global_id[0]);
    let y = f32(global_id[1]);
    let x_0 = params.x_0;
    let y_0 = params.y_0;
    let sigma_0 = params.sigma_0;
    let p_0 = params.p_0;
    buffer[global_id[0]+global_id[1]*params.width].real = pow(1.0/(2.0*3.1415*sigma_0*sigma_0),0.25)*exp(-((x-x_0)*(x-x_0)+(y-y_0)*(y-y_0))/(4.0*sigma_0*sigma_0))*cos(p_0*x);
    buffer[global_id[0]+global_id[1]*params.width].imaginary = pow(1.0/(2.0*3.1415*sigma_0*sigma_0),0.25)*exp(-((x-x_0)*(x-x_0)+(y-y_0)*(y-y_0))/(4.0*sigma_0*sigma_0))*sin(p_0*x);
}

@compute
@workgroup_size(1)
fn k1(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let i = (global_id[0]+1u)+(global_id[1]+1u)*params.width;
    let b = params.width*params.height;
    buffer[i+b]=ComplexNumber(
        params.delta_t*(buffer[i + 1u].imaginary + buffer[i - 1u].imaginary + buffer[i + params.width].imaginary + buffer[i - params.width].imaginary - 4.0*buffer[i].imaginary + buffer[i].imaginary*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0)))),
        params.delta_t*(- buffer[i + 1u].real - buffer[i - 1u].real - buffer[i + params.width].real - buffer[i - params.width].real + 4.0*buffer[i].real - buffer[i].real*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0))))
    );
}

@compute
@workgroup_size(1)
fn k2(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let i = (global_id[0]+1u)+(global_id[1]+1u)*params.width;
    let b = params.width*params.height;
    buffer[i+2u*b]=ComplexNumber(
        buffer[i+b].real+params.delta_t*0.5*(buffer[i + b + 1u].imaginary + buffer[i + b - 1u].imaginary + buffer[i + b + params.width].imaginary + buffer[i + b - params.width].imaginary - 4.0*buffer[i + b].imaginary + buffer[i+b].imaginary*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0)))),
        buffer[i+b].imaginary+params.delta_t*0.5*(- buffer[i + b + 1u].real - buffer[i + b - 1u].real - buffer[i + b + params.width].real - buffer[i + b - params.width].real + 4.0*buffer[i + b].real - buffer[i+b].real*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0))))
    );
}

@compute
@workgroup_size(1)
fn k3(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let i = (global_id[0]+1u)+(global_id[1]+1u)*params.width;
    let b = params.width*params.height;
    buffer[i+3u*b]=ComplexNumber(
        buffer[i+b].real+params.delta_t*0.5*(buffer[i + 2u*b + 1u].imaginary + buffer[i + 2u*b - 1u].imaginary + buffer[i + 2u*b + params.width].imaginary + buffer[i + 2u*b - params.width].imaginary - 4.0*buffer[i + 2u*b].imaginary + buffer[i+2u*b].imaginary*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0)))),
        buffer[i+b].imaginary+params.delta_t*0.5*(- buffer[i + 2u*b + 1u].real - buffer[i + 2u*b - 1u].real - buffer[i + 2u*b + params.width].real - buffer[i + 2u*b - params.width].real + 4.0*buffer[i + 2u*b].real - buffer[i + 2u*b].real*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0))))
    );
}

@compute
@workgroup_size(1)
fn k4(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let i = (global_id[0]+1u)+(global_id[1]+1u)*params.width;
    let b = params.width*params.height;
    buffer[i+4u*b]=ComplexNumber(
        buffer[i+b].real+params.delta_t*(buffer[i + 3u*b + 1u].imaginary + buffer[i + 3u*b - 1u].imaginary + buffer[i + 3u*b + params.width].imaginary + buffer[i + 3u*b - params.width].imaginary - 4.0*buffer[i + 3u*b].imaginary + buffer[i + 3u*b].imaginary*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0)))),
        buffer[i+b].imaginary+params.delta_t*(- buffer[i + 3u*b + 1u].real - buffer[i + 3u*b - 1u].real - buffer[i + 3u*b + params.width].real - buffer[i + 3u*b - params.width].real + 4.0*buffer[i + 3u*b].real - buffer[i + 3u*b].real*64.0*f32((f32(params.width)*7.0/32.0<f32(global_id[0])&&f32(global_id[0])<f32(params.width)*8.0/32.0)&&(((f32(global_id[1])>f32(params.height)*18.0/32.0))|(f32(global_id[1])<f32(params.height)*17.0/32.0&&f32(global_id[1])>f32(params.height)*15.0/32.0)|(f32(global_id[1])<f32(params.height)*14.0/32.0))))
    );
}

@compute
@workgroup_size(1)
fn psi(@builtin(global_invocation_id) global_id: vec3<u32>) {
    let i = (global_id[0]+1u)+(global_id[1]+1u)*params.width;
    let b = params.width*params.height;
    buffer[i]=ComplexNumber(
        buffer[i].real + buffer[i + b].real/6.0 + buffer[i + 2u*b].real/3.0 + buffer[i + 3u*b].real/3.0 + buffer[i + 4u*b].real/6.0,
        buffer[i].imaginary + buffer[i + b].imaginary/6.0 + buffer[i + 2u*b].imaginary/3.0 + buffer[i + 3u*b].imaginary/3.0 + buffer[i + 4u*b].imaginary/6.0
    );
}
