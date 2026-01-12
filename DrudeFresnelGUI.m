function DrudeFresnelGUI()
    % Creación de la Interfaz Gráfica (GUI)
    handles = struct();
    handles.files = struct(); 

    % 1. Figura Principal: cuadricula 2x2 con cuatro secciones
    handles.fig = figure('Name', 'GUI Drude-Lorentz y Fresnel', ...
                         'NumberTitle', 'off', ...
                         'Units', 'pixels', ...
                         'Position', [100, 100, 1160, 600], ... 
                         'MenuBar', 'none', ...
                         'Resize', 'off', ...
                         'DockControls', 'off');

    % COLUMNA IZQUIERDA
    % 2.A. Panel de Archivos Drude-Lorentz (Arriba Izquierda)
    handles.panel_files = uipanel('Parent', handles.fig, ...
                                  'Title', 'Archivos de Entrada para el Modelo de Drude-Lorentz (.txt)', ...
                                  'Units', 'pixels', ...
                                  'Position', [20, 290, 550, 260]); 

    file_inputs = {
        'f',     'Fuerzas (f):',            [20, 210];
        'gamma', 'Gamma (γ):',             [20, 170];
        'omega', 'Omega (ω):',             [20, 130];
        'wvl_exp', 'Vector λ experimental:',      [20, 90];
        'n_exp', 'n(λ) experimental:',   [20, 50];
        'k_exp', 'k(λ) experimental:',   [20, 10]
    };

    for i = 1:size(file_inputs, 1)
        key = file_inputs{i, 1};
        label_text = file_inputs{i, 2};
        pos = file_inputs{i, 3};
        
        uicontrol('Parent', handles.panel_files, 'Style', 'text', ...
                  'String', label_text, 'HorizontalAlignment', 'right', ...
                  'Position', [pos(1), pos(2)+5, 120, 20]);
        
        handles.(['edit_' key]) = uicontrol('Parent', handles.panel_files, 'Style', 'edit', ...
                                     'String', 'No seleccionado...', 'HorizontalAlignment', 'left', ...
                                     'Enable', 'inactive', 'Position', [pos(1)+130, pos(2), 280, 25]);
        
        handles.(['btn_' key]) = uicontrol('Parent', handles.panel_files, 'Style', 'pushbutton', ...
                                    'String', 'Examinar...', 'Position', [pos(1)+420, pos(2), 80, 25], ...
                                    'Callback', {@browseFile, key}); 
    end

    % 2.B. Panel de Parámetros Fresnel (Abajo Izquierda)
    handles.panel_fresnel = uipanel('Parent', handles.fig, ...
                                    'Title', 'Coeficientes de Fresnel: Barrido Angular (λ Fija)', ...
                                    'Units', 'pixels', ...
                                    'Position', [20, 100, 550, 170]); 

    uicontrol('Parent', handles.panel_fresnel, 'Style', 'text', ...
              'String', 'Longitud de Onda Fija (nm):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 125, 180, 20]);
    handles.edit_wvl_i = uicontrol('Parent', handles.panel_fresnel, 'Style', 'edit', ...
                                  'String', '633', 'Position', [210, 125, 100, 25]);

    uicontrol('Parent', handles.panel_fresnel, 'Style', 'text', ...
              'String', 'n experimental (en λ fija):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 90, 180, 20]);
    handles.edit_n_exp_fresnel = uicontrol('Parent', handles.panel_fresnel, 'Style', 'edit', ... 
                                  'String', '', 'Position', [210, 90, 100, 25]);

    uicontrol('Parent', handles.panel_fresnel, 'Style', 'text', ...
              'String', 'k experimental (en λ fija):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 55, 180, 20]);
    handles.edit_k_exp_fresnel = uicontrol('Parent', handles.panel_fresnel, 'Style', 'edit', ... 
                                  'String', '', 'Position', [210, 55, 100, 25]);

    uicontrol('Parent', handles.panel_fresnel, 'Style', 'text', ...
              'String', 'Dirección de Incidencia:', 'HorizontalAlignment', 'right', ...
              'Position', [20, 20, 180, 20]);
    handles.popup_direccion = uicontrol('Parent', handles.panel_fresnel, 'Style', 'popupmenu', ...
                                        'String', {'1: Aire -> Material', '2: Material -> Aire'}, ...
                                        'Position', [210, 20, 200, 25]);

    % COLUMNA DERECHA
    % 3.A. Panel de Simulación y Drude (Arriba Derecha)
    handles.panel_sim_drude = uipanel('Parent', handles.fig, ...
                                  'Title', 'Parámetros de Simulación Generales', ...
                                  'Units', 'pixels', ...
                                  'Position', [590, 290, 550, 260]);
    
    uicontrol('Parent', handles.panel_sim_drude, 'Style', 'text', ...
              'String', 'Tipo de Material:', 'HorizontalAlignment', 'right', ...
              'Position', [20, 215, 120, 20]);
    handles.popup_material = uicontrol('Parent', handles.panel_sim_drude, 'Style', 'popupmenu', ...
                                       'String', {'Metal', 'Dieléctrico/Semiconductor'}, ...
                                       'Position', [150, 215, 200, 25], 'Callback', @materialChange); 

    uicontrol('Parent', handles.panel_sim_drude, 'Style', 'text', ...
              'String', 'e_inf (si aplica):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 180, 120, 20]);
    % Por defecto Metal: e_inf desactivado
    handles.edit_e_inf = uicontrol('Parent', handles.panel_sim_drude, 'Style', 'edit', ...
                                   'String', '2.18', 'Position', [150, 180, 100, 25], 'Enable', 'off'); 

    uicontrol('Parent', handles.panel_sim_drude, 'Style', 'text', ...
              'String', 'λ min (nm):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 145, 120, 20]);
    handles.edit_wvl_min = uicontrol('Parent', handles.panel_sim_drude, 'Style', 'edit', ...
                                     'String', '300', 'Position', [150, 145, 100, 25]);
    
    uicontrol('Parent', handles.panel_sim_drude, 'Style', 'text', ...
              'String', 'λ max (nm):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 110, 120, 20]);
    handles.edit_wvl_max = uicontrol('Parent', handles.panel_sim_drude, 'Style', 'edit', ...
                                     'String', '700', 'Position', [150, 110, 100, 25]);

    uicontrol('Parent', handles.panel_sim_drude, 'Style', 'text', ...
              'String', 'Paso (nm):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 75, 120, 20]);
    handles.edit_paso = uicontrol('Parent', handles.panel_sim_drude, 'Style', 'edit', ...
                                  'String', '1', 'Position', [150, 75, 100, 25]);
                                  
    uicontrol('Parent', handles.panel_sim_drude, 'Style', 'text', ...
              'String', 'ω_p (eV o Escala):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 40, 120, 20]);
    % Por defecto Metal: wp activado
    handles.edit_omegapin = uicontrol('Parent', handles.panel_sim_drude, 'Style', 'edit', ...
                                      'String', '9.01', 'Position', [150, 40, 100, 25], 'Enable', 'on');

    % 3.B. Panel de Barrido Espectral (Abajo Derecha)
    handles.panel_spectral = uipanel('Parent', handles.fig, ...
                                     'Title', 'Coeficientes de Fresnel: Barrido Espectral (Ángulo Fijo)', ...
                                     'Units', 'pixels', ...
                                     'Position', [590, 100, 550, 170]); 
    
    uicontrol('Parent', handles.panel_spectral, 'Style', 'text', ...
              'String', 'Ángulo de Incidencia Fijo (grados):', 'HorizontalAlignment', 'right', ...
              'Position', [20, 75, 220, 20]); 
    handles.edit_theta_i_fijo = uicontrol('Parent', handles.panel_spectral, 'Style', 'edit', ...
                                          'String', '60', 'Position', [250, 75, 100, 25]); 


    % 4. Botones de Control (Centrados)
    handles.btn_run = uicontrol('Parent', handles.fig, ...
                                'Style', 'pushbutton', ...
                                'String', 'CALCULAR Y GRAFICAR', ...
                                'FontSize', 12, 'FontWeight', 'bold', ...
                                'Position', [430, 50, 300, 40], ... 
                                'Callback', @runCalculation); 

    handles.btn_close = uicontrol('Parent', handles.fig, ...
                                  'Style', 'pushbutton', ...
                                  'String', 'Cerrar', ...
                                  'Position', [530, 20, 100, 25], ... 
                                  'Callback', 'close(gcbf)'); 


    % FIN DE LA CONSTRUCCIÓN DE LA GUI

    % FUNCIONES CALLBACK ANIDADAS

    function browseFile(src, evt, fileKey)
        [filename, pathname] = uigetfile('*.txt', ['Seleccionar archivo para ' fileKey]);
        if filename ~= 0
            full_path = fullfile(pathname, filename);
            handles.files.(fileKey) = full_path;
            edit_handle_name = ['edit_' fileKey];
            set(handles.(edit_handle_name), 'String', full_path);
            disp(['Archivo ' fileKey ' seleccionado: ' full_path]);
        end
    end

    function materialChange(src, evt)
        val = get(handles.popup_material, 'Value');
        if val == 1 % Metal
            set(handles.edit_e_inf, 'Enable', 'off'); % Bloquear e_inf
            set(handles.edit_omegapin, 'Enable', 'on');  % Permitir editar wp
        else % Dieléctrico/Semiconductor
            set(handles.edit_e_inf, 'Enable', 'on');  % Permitir editar e_inf
            set(handles.edit_omegapin, 'Enable', 'off'); % Bloquear wp (Usará el valor que tenga)
        end
    end

 % FUNCIÓN PRINCIPAL DE CÁLCULO
    function runCalculation(src, evt)
        
        disp('Iniciando cálculo...');
        set(handles.fig, 'Pointer', 'watch');
        
        try
            %  A. Recolección y Validación de Datos
            
            % 1. Validar Archivos
            file_keys = {'f', 'gamma', 'omega', 'wvl_exp', 'n_exp', 'k_exp'};
            for k = 1:length(file_keys)
                key = file_keys{k};
                if ~isfield(handles.files, key) || ~exist(handles.files.(key), 'file')
                    errordlg(['El archivo para "' key '" no ha sido seleccionado o no existe.'], 'Error de Archivo');
                    set(handles.fig, 'Pointer', 'arrow');
                    return;
                end
            end
            
            % 2. Obtener Parámetros Drude y Simulación
            tipo_material_val = get(handles.popup_material, 'Value');
            e_inf = str2double(get(handles.edit_e_inf, 'String'));
            wvl_min_nm = str2double(get(handles.edit_wvl_min, 'String'));
            wvl_max_nm = str2double(get(handles.edit_wvl_max, 'String'));
            paso_nm = str2double(get(handles.edit_paso, 'String'));
            omegapin = str2double(get(handles.edit_omegapin, 'String'));
            
            % Validación de Parámetros de Simulación
            % Nota: Aunque omegapin esté deshabilitado en la GUI, leemos su valor para usarlo en el cálculo (si es necesario como factor de escala)
            if (isnan(e_inf) && tipo_material_val == 2) || isnan(wvl_min_nm) || isnan(wvl_max_nm) || isnan(paso_nm) || isnan(omegapin)
                 errordlg('Los parámetros de simulación (e_inf, λ, paso, omegap) deben ser números válidos.', 'Error de Entrada');
                 set(handles.fig, 'Pointer', 'arrow');
                 return;
            end
            
            % 3. Obtener Parámetros Fresnel: Barrido Angular
            wvl_i = str2double(get(handles.edit_wvl_i, 'String'));
            n_exp_user = str2double(get(handles.edit_n_exp_fresnel, 'String')); 
            k_exp_user = str2double(get(handles.edit_k_exp_fresnel, 'String')); 
            direccion = get(handles.popup_direccion, 'Value');
            
            if isnan(wvl_i) || isnan(n_exp_user) || isnan(k_exp_user)
                errordlg('Los parámetros de Fresnel (λ, n, k) deben ser números válidos.', 'Error de Entrada');
                set(handles.fig, 'Pointer', 'arrow');
                return;
            end
            
            % 4. Obtener Parámetros Fresnel: Barrido Espectral
            theta_i_fijo_deg = str2double(get(handles.edit_theta_i_fijo, 'String'));
            if isnan(theta_i_fijo_deg) || theta_i_fijo_deg < 0 || theta_i_fijo_deg > 90
                errordlg('El ángulo de incidencia fijo debe ser un número entre 0 y 90.', 'Error de Entrada');
                set(handles.fig, 'Pointer', 'arrow');
                return;
            end
            theta_i_fijo_rad = deg2rad(theta_i_fijo_deg);

            
            % B. Calculos del Modelo Drude-Lorentz
            
            disp('Paso 1: Ejecutando el Modelo Drude-Lorentz...');
            
            % Parametros de simulación
            wvl_min = wvl_min_nm * 1e-9; % [m]
            wvl_max = wvl_max_nm * 1e-9; % [m]
            paso = paso_nm * 1e-9;      % [m]
            wvl = wvl_min:paso:wvl_max;
            
            c = 299792458;
            ehbar = 1.51926751447914e+15;
            w = 2*pi*c./wvl;
            omegap = omegapin * ehbar; 
            
            % Carga de datos (usando las rutas del GUI)
            f = load(handles.files.f);
            gamma_base = load(handles.files.gamma); 
            gamma = gamma_base * ehbar;
            omega_base = load(handles.files.omega); 
            omega = omega_base * ehbar;

            N = length(omega);
            
            % --- CÁLCULO MODIFICADO: Metal vs Dieléctrico ---
            if tipo_material_val == 1 % 'Metal'
                disp('Calculando permitividad para un Metal (Drude + Lorentz).');
                
                % 1. Parte de Drude (Usa el primer parámetro, k=1)
                e_D = ones(size(wvl)) - (f(1)*omegap^2) ./ (w.^2 + 1i*gamma(1).*w);
                
                % 2. Parte de Lorentz (Usa el resto, k=2 a N)
                e_L = zeros(size(wvl));
                for k = 2:N
                    e_L = e_L + (f(k) * omegap^2) ./ (omega(k)^2*ones(size(wvl)) - ...
                    w.^2 - 1i*gamma(k).*w);
                end
                
                e_model = e_D + e_L; % Total Metal
                
            else % 'Dielectrico/Semiconductor'
                disp('Calculando permitividad para un Dieléctrico (Modelo de Lorentz puro + e_inf).');
                
                % 1. Parte constante (Fondo)
                e_D = e_inf * ones(size(wvl)); 
                
                % 2. Parte de Lorentz (Usa TODOS los osciladores, k=1 a N)
                % Se usa 'omegap' como factor de escala (incluso si está bloqueado en GUI, se lee el valor presente)
                e_L = zeros(size(wvl));
                for k = 1:N
                    e_L = e_L + (f(k) * omega(k)^2) ./ (omega(k)^2*ones(size(wvl)) - ...
                    w.^2 - 1i*gamma(k).*w);
                end
                
                e_model = e_D + e_L; % Total Dieléctrico
            end
            % ------------------------------------------------
            
            % Gráfica 1: Desglose de Permitividad
            wvl_model_nm = wvl * 1e9; % Vector de longitud de onda en nm
            figure; 
            sgtitle('Desglose de la Permitividad Dieléctrica');
            subplot(3, 2, 1); plot(wvl_model_nm, real(e_D), 'b', 'LineWidth', 2); grid on; title('Re(\epsilon_D / Fondo)'); xlim([wvl_min*1e9, wvl_max*1e9]);
            subplot(3, 2, 2); plot(wvl_model_nm, imag(e_D), 'r', 'LineWidth', 2); grid on; title('Im(\epsilon_D / Fondo)'); xlim([wvl_min*1e9, wvl_max*1e9]);
            subplot(3, 2, 3); plot(wvl_model_nm, real(e_L), 'b', 'LineWidth', 2); grid on; title('Re(\epsilon_L)'); xlim([wvl_min*1e9, wvl_max*1e9]);
            subplot(3, 2, 4); plot(wvl_model_nm, imag(e_L), 'r', 'LineWidth', 2); grid on; title('Im(\epsilon_L)'); xlim([wvl_min*1e9, wvl_max*1e9]);
            subplot(3, 2, 5); plot(wvl_model_nm, real(e_model), 'b', 'LineWidth', 2); grid on; title('Re(\epsilon Total)'); xlim([wvl_min*1e9, wvl_max*1e9]);
            subplot(3, 2, 6); plot(wvl_model_nm, imag(e_model), 'r', 'LineWidth', 2); grid on; title('Im(\epsilon Total)'); xlim([wvl_min*1e9, wvl_max*1e9]);
            
            % Cálculo del índice de refracción (modelo)
            n_complejo_MODELO_calculado = sqrt(e_model);
            n_modelo = real(n_complejo_MODELO_calculado);
            k_modelo = imag(n_complejo_MODELO_calculado);
            
            % Carga de datos experimentales (de los archivos del GUI)
            wvl_exp_nm = load(handles.files.wvl_exp);
            n_exp_archivo = load(handles.files.n_exp);
            k_exp_archivo = load(handles.files.k_exp);
            n_complejo_USER_vec = n_exp_archivo + 1i*k_exp_archivo;

            % Gráfica 2: Comparación n y k
            figure; 
            sgtitle('Comparación: Modelo Drude-Lorentz vs. Experimental');
            subplot(2, 1, 1);
            plot(wvl_model_nm, n_modelo, 'b-', 'LineWidth', 2, 'DisplayName', 'Modelo Drude-Lorentz'); hold on;
            plot(wvl_exp_nm, n_exp_archivo, 'bo', 'MarkerFaceColor', 'b', 'DisplayName', 'Experimental (Archivo)'); hold off;
            title('Índice de Refracción (n)'); xlabel('\lambda (nm)'); ylabel('n'); grid on; legend('show'); xlim([wvl_min*1e9 wvl_max*1e9]);
            subplot(2, 1, 2);
            plot(wvl_model_nm, k_modelo, 'r-', 'LineWidth', 2, 'DisplayName', 'Modelo Drude-Lorentz'); hold on;
            plot(wvl_exp_nm, k_exp_archivo, 'ro', 'MarkerFaceColor', 'r', 'DisplayName', 'Experimental (Archivo)'); hold off;
            title('Coeficiente de Extinción (k)'); xlabel('\lambda (nm)'); ylabel('k'); grid on; legend('show'); xlim([wvl_min*1e9 wvl_max*1e9]);

            
            %  Calculo de los Coeficientes de Fresnel
            
            disp('Paso 2: Ejecutando cálculos de Fresnel...');
            
            % 1. Datos experimentales del usuario (del GUI, Bloque 2)
            n_complejo_USER = n_exp_user + 1i*k_exp_user; 
            
            % 2. Parámetros y Preparación
            n_i = 1.0; % Aire
            
            if direccion == 1 
                disp('Calculando para luz incidente desde Medio 1 (Aire) a Medio 2 (Material).');
                xlabel_text_angle = 'Ángulo de incidencia en Medio 1 (Aire) [grados]';
            else
                disp('Calculando para luz incidente desde Medio 2 (Material) a Medio 1 (Aire).');
                xlabel_text_angle = 'Ángulo de incidencia en Medio 2 (Material) [grados]';
            end
            xlabel_text_wvl = 'Longitud de Onda (\lambda) [nm]'; 

            theta_i_deg = 0:1:90;
            theta_i_rad = deg2rad(theta_i_deg);
            cos_i = cos(theta_i_rad); 
            
            n_complejo_MODELO_mat = sqrt(e_model); % Vector [1, N_wvl]

            % Inicialización de matrices
            num_angulos = length(theta_i_rad);
            num_wvl = length(wvl_model_nm);
            r_perp_mat_MODELO = zeros(num_angulos, num_wvl);
            r_para_mat_MODELO = zeros(num_angulos, num_wvl);
            t_perp_mat_MODELO = zeros(num_angulos, num_wvl);
            t_para_mat_MODELO = zeros(num_angulos, num_wvl);

            % 3. Bucle Principal para el Modelo (Calculo de las matrices r_i(theta,lambda) y t_i(theta,lambda))
            for j = 1:num_wvl
                n_material_actual = n_complejo_MODELO_mat(j);

                if direccion == 1
                    n_inc = n_i; n_tra = n_material_actual;
                else
                    n_inc = n_material_actual; n_tra = n_i;
                end
                
                cos_theta_i = cos(theta_i_rad);
                sin_theta_t = (n_inc / n_tra) * sin(theta_i_rad);
                cos_theta_t = sqrt(1 - sin_theta_t.^2);

                r_perp_mat_MODELO(:, j) = (n_inc * cos_theta_i - n_tra * cos_theta_t) ./ (n_inc * cos_theta_i + n_tra * cos_theta_t);
                r_para_mat_MODELO(:, j) = (n_tra * cos_theta_i - n_inc * cos_theta_t) ./ (n_inc * cos_theta_t + n_tra * cos_theta_i);
                t_perp_mat_MODELO(:, j) = (2 * n_inc * cos_theta_i) ./ (n_inc * cos_theta_i + n_tra * cos_theta_t);
                t_para_mat_MODELO(:, j) = (2 * n_inc * cos_theta_i) ./ (n_inc * cos_theta_t + n_tra * cos_theta_i);
            end

            % 4. Cálculo Fresnel (para una sola lambda introducida por el usuario y los datos experimentales correspondientes)
            n_material_USER = n_complejo_USER;

            if direccion == 1
                n_inc_USER = n_i; n_tra_USER = n_material_USER;
            else
                n_inc_USER = n_material_USER; n_tra_USER = n_i;
            end

            cos_theta_i = cos(theta_i_rad);
            sin_theta_t_USER = (n_inc_USER / n_tra_USER) * sin(theta_i_rad);
            cos_theta_t_USER = sqrt(1 - sin_theta_t_USER.^2);

            r_perp_USER = (n_inc_USER * cos_theta_i - n_tra_USER * cos_theta_t_USER) ./ (n_inc_USER * cos_theta_i + n_tra_USER * cos_theta_t_USER);
            r_para_USER = (n_tra_USER * cos_theta_i - n_inc_USER * cos_theta_t_USER) ./ (n_inc_USER * cos_theta_t_USER + n_tra_USER * cos_theta_i);
            t_perp_USER = (2 * n_inc_USER * cos_theta_i) ./ (n_inc_USER * cos_theta_i + n_tra_USER * cos_theta_t_USER);
            t_para_USER = (2 * n_inc_USER * cos_theta_i) ./ (n_inc_USER * cos_theta_t_USER + n_tra_USER * cos_theta_i);
            
            % 5. Visualización de Resultados: Gráfica 3 - Amplitud y Fase para el Barrido Angular
            [~, idx_wvl] = min(abs(wvl_model_nm - wvl_i)); % Buscar índice de la lambda deseada

            r_perp_MODELO = r_perp_mat_MODELO(:, idx_wvl);
            r_para_MODELO = r_para_mat_MODELO(:, idx_wvl);
            t_perp_MODELO = t_perp_mat_MODELO(:, idx_wvl);
            t_para_MODELO = t_para_mat_MODELO(:, idx_wvl);

            figure('Name', ['Barrido Angular: Amplitud y Fase a ' num2str(wvl_i) ' nm - Comparación']); 
            
            subplot(2, 2, 1);
            plot(theta_i_deg, abs(r_perp_MODELO), 'b-', 'LineWidth', 2, 'DisplayName', '|r_s| - Modelo'); hold on;
            plot(theta_i_deg, abs(r_para_MODELO), 'r--', 'LineWidth', 2, 'DisplayName', '|r_p| - Modelo');
            plot(theta_i_deg, abs(r_perp_USER), 'b:', 'LineWidth', 1.5, 'DisplayName', '|r_s| - Exp.');
            plot(theta_i_deg, abs(r_para_USER), 'r:', 'LineWidth', 1.5, 'DisplayName', '|r_p| - Exp.');
            title('Amplitud de Reflexión'); xlabel(xlabel_text_angle); ylabel('Amplitud |r|');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
            
            subplot(2, 2, 2);
            plot(theta_i_deg, abs(t_perp_MODELO), 'b-', 'LineWidth', 2, 'DisplayName', '|t_s| - Modelo'); hold on;
            plot(theta_i_deg, abs(t_para_MODELO), 'r--', 'LineWidth', 2, 'DisplayName', '|t_p| - Modelo');
            plot(theta_i_deg, abs(t_perp_USER), 'b:', 'LineWidth', 1.5, 'DisplayName', '|t_s| - Exp.');
            plot(theta_i_deg, abs(t_para_USER), 'r:', 'LineWidth', 1.5, 'DisplayName', '|t_p| - Exp.');
            title('Amplitud de Transmisión'); xlabel(xlabel_text_angle); ylabel('Amplitud |t|');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
       
            subplot(2, 2, 3);
            plot(theta_i_deg, rad2deg(angle(r_perp_MODELO)), 'b-', 'LineWidth', 2, 'DisplayName', 'Fase(r_s) - Modelo'); hold on;
            plot(theta_i_deg, rad2deg(angle(r_para_MODELO)), 'r--', 'LineWidth', 2, 'DisplayName', 'Fase(r_p) - Modelo');
            plot(theta_i_deg, rad2deg(angle(r_perp_USER)), 'b:', 'LineWidth', 1.5, 'DisplayName', 'Fase(r_s) - Exp.');
            plot(theta_i_deg, rad2deg(angle(r_para_USER)), 'r:', 'LineWidth', 1.5, 'DisplayName', 'Fase(r_p) - Exp.');
            title('Fase de Reflexión'); xlabel(xlabel_text_angle); ylabel('Fase [grados]');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]); ylim([-180 180]); yticks(-180:90:180);
            
            subplot(2, 2, 4);
            plot(theta_i_deg, rad2deg(angle(t_perp_MODELO)), 'b-', 'LineWidth', 2, 'DisplayName', 'Fase(t_s) - Modelo'); hold on;
            plot(theta_i_deg, rad2deg(angle(t_para_MODELO)), 'r--', 'LineWidth', 2, 'DisplayName', 'Fase(t_p) - Modelo');
            plot(theta_i_deg, rad2deg(angle(t_perp_USER)), 'b:', 'LineWidth', 1.5, 'DisplayName', 'Fase(t_s) - Exp.');
            plot(theta_i_deg, rad2deg(angle(t_para_USER)), 'r:', 'LineWidth', 1.5, 'DisplayName', 'Fase(t_p) - Exp.');
            title('Fase de Transmisión'); xlabel(xlabel_text_angle); ylabel('Fase [grados]');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
            ylim([-180 180]); yticks(-180:90:180);

            % Cálculos de ENERGÍA
            
            R_perp_MODELO = abs(r_perp_MODELO).^2;
            R_para_MODELO = abs(r_para_MODELO).^2;
            R_perp_USER = abs(r_perp_USER).^2;
            R_para_USER = abs(r_para_USER).^2;

            n_material_MODELO_idx = n_complejo_MODELO_mat(idx_wvl);
            
            if direccion == 1
                n_inc_MODELO = n_i;
                n_tra_MODELO = n_material_MODELO_idx;
            else
                n_inc_MODELO = n_material_MODELO_idx;
                n_tra_MODELO = n_i;
            end
            
            sin_theta_t_MODELO = (n_inc_MODELO / n_tra_MODELO) * sin(theta_i_rad);
            cos_theta_t_MODELO = sqrt(1 - sin_theta_t_MODELO.^2);

            factor_T_MODELO = (real(n_tra_MODELO * cos_theta_t_MODELO)) ./ (real(n_inc_MODELO * cos_i));
            factor_T_USER   = (real(n_tra_USER * cos_theta_t_USER)) ./ (real(n_inc_USER * cos_i));
            
            T_perp_MODELO = factor_T_MODELO' .* abs(t_perp_MODELO).^2;
            T_para_MODELO = factor_T_MODELO' .* abs(t_para_MODELO).^2;
            T_perp_USER   = factor_T_USER   .* abs(t_perp_USER).^2;
            T_para_USER   = factor_T_USER   .* abs(t_para_USER).^2;

            T_perp_MODELO(isnan(T_perp_MODELO) | isinf(T_perp_MODELO)) = 0;
            T_para_MODELO(isnan(T_para_MODELO) | isinf(T_para_MODELO)) = 0;
            T_perp_USER(isnan(T_perp_USER) | isinf(T_perp_USER)) = 0;
            T_para_USER(isnan(T_para_USER) | isinf(T_para_USER)) = 0;

            
            % Gráfica 4: Coeficientes de ENERGÍA en Barrido Angular
            
            figure('Name', ['Barrido Angular: Energía (R, T) a ' num2str(wvl_i) ' nm - Comparación']);
            
            subplot(2, 2, 1);
            plot(theta_i_deg, R_perp_MODELO, 'g-', 'LineWidth', 2, 'DisplayName', 'R_s - Modelo'); hold on;
            plot(theta_i_deg, R_perp_USER, 'r:', 'LineWidth', 1.5, 'DisplayName', 'R_s - Exp.');
            title('Reflectancia (R_s)');
            xlabel(xlabel_text_angle); ylabel('Reflectancia R');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
            data_Rs = [R_perp_MODELO(:); R_perp_USER(:)];
            setAxisLimits(data_Rs);

            subplot(2, 2, 2);
            plot(theta_i_deg, T_perp_MODELO, 'g-', 'LineWidth', 2, 'DisplayName', 'T_s - Modelo'); hold on;
            plot(theta_i_deg, T_perp_USER, 'r:', 'LineWidth', 1.5, 'DisplayName', 'T_s - Exp.');
            title('Transmitancia (T_s)');
            xlabel(xlabel_text_angle); ylabel('Transmitancia T');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
            data_Ts = [T_perp_MODELO(:); T_perp_USER(:)];
            setAxisLimits(data_Ts);

            subplot(2, 2, 3);
            plot(theta_i_deg, R_para_MODELO, 'g-', 'LineWidth', 2, 'DisplayName', 'R_p - Modelo'); hold on;
            plot(theta_i_deg, R_para_USER, 'r:', 'LineWidth', 1.5, 'DisplayName', 'R_p - Exp.');
            title('Reflectancia (R_p)');
            xlabel(xlabel_text_angle); ylabel('Reflectancia R');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
            data_Rp = [R_para_MODELO(:); R_para_USER(:)];
            setAxisLimits(data_Rp);

            subplot(2, 2, 4);
            plot(theta_i_deg, T_para_MODELO, 'g-', 'LineWidth', 2, 'DisplayName', 'T_p - Modelo'); hold on;
            plot(theta_i_deg, T_para_USER, 'r:', 'LineWidth', 1.5, 'DisplayName', 'T_p - Exp.');
            title('Transmitancia (T_p)');
            xlabel(xlabel_text_angle); ylabel('Transmitancia T');
            legend('show', 'Location', 'best'); grid on; xlim([0 90]);
            data_Tp = [T_para_MODELO(:); T_para_USER(:)];
            setAxisLimits(data_Tp);
            
            
            % CÁLCULOS Y GRÁFICAS PARA BARRIDO ESPECTRAL (Ángulo Fijo)
            
            disp('Paso 3: Ejecutando Cálculos de Barrido Espectral (Ángulo Fijo)...');
            
            % 3.A: EXTRACCIÓN de datos del MODELO (ya tenemos las matrices r_i y t_i para cualquier theta y lambda)
            [~, idx_angle] = min(abs(theta_i_deg - theta_i_fijo_deg)); % Buscar índice del ángulo
            
            r_perp_MODELO_vs_wvl = r_perp_mat_MODELO(idx_angle, :); % Fila [1, N_wvl]
            r_para_MODELO_vs_wvl = r_para_mat_MODELO(idx_angle, :); 
            t_perp_MODELO_vs_wvl = t_perp_mat_MODELO(idx_angle, :); 
            t_para_MODELO_vs_wvl = t_para_mat_MODELO(idx_angle, :); 
            
            R_perp_MODELO_vs_wvl = abs(r_perp_MODELO_vs_wvl).^2;
            R_para_MODELO_vs_wvl = abs(r_para_MODELO_vs_wvl).^2;
            
            %  3.B: CÁLCULO de datos EXPERIMENTALES
            cos_i_fijo = cos(theta_i_fijo_rad); % Escalar
            sin_i_fijo = sin(theta_i_fijo_rad); % Escalar
            
            % n_complejo_USER_vec es [N_exp, 1] (columna)
            if direccion == 1
                n_inc_USER_vec = n_i; % Escalar
                n_tra_USER_vec = n_complejo_USER_vec; % Vector [N_exp, 1]
            else
                n_inc_USER_vec = n_complejo_USER_vec; 
                n_tra_USER_vec = n_i; 
            end

            sin_theta_t_USER_vec = (n_inc_USER_vec ./ n_tra_USER_vec) * sin_i_fijo;
            cos_theta_t_USER_vec = sqrt(1 - sin_theta_t_USER_vec.^2); 
            
            r_perp_USER_vs_wvl = (n_inc_USER_vec * cos_i_fijo - n_tra_USER_vec .* cos_theta_t_USER_vec) ./ (n_inc_USER_vec * cos_i_fijo + n_tra_USER_vec .* cos_theta_t_USER_vec);
            r_para_USER_vs_wvl = (n_tra_USER_vec * cos_i_fijo - n_inc_USER_vec .* cos_theta_t_USER_vec) ./ (n_inc_USER_vec .* cos_theta_t_USER_vec + n_tra_USER_vec * cos_i_fijo);
            t_perp_USER_vs_wvl = (2 * n_inc_USER_vec * cos_i_fijo) ./ (n_inc_USER_vec * cos_i_fijo + n_tra_USER_vec .* cos_theta_t_USER_vec);
            t_para_USER_vs_wvl = (2 * n_inc_USER_vec * cos_i_fijo) ./ (n_inc_USER_vec .* cos_theta_t_USER_vec + n_tra_USER_vec * cos_i_fijo);

            R_perp_USER_vs_wvl = abs(r_perp_USER_vs_wvl).^2;
            R_para_USER_vs_wvl = abs(r_para_USER_vs_wvl).^2;

            % 3.C: CÁLCULO de T (Transmitancia)
            
            % T Modelo
            if direccion == 1
                n_inc_MODELO_vec = n_i; 
                n_tra_MODELO_vec = n_complejo_MODELO_mat; % Vector [1, N_wvl]
            else
                n_inc_MODELO_vec = n_complejo_MODELO_mat; 
                n_tra_MODELO_vec = n_i; 
            end
            
            sin_theta_t_MODELO_vec = (n_inc_MODELO_vec ./ n_tra_MODELO_vec) * sin_i_fijo;
            cos_theta_t_MODELO_vec = sqrt(1 - sin_theta_t_MODELO_vec.^2); % Vector [1, N_wvl]
            
            factor_T_MODELO_vec = (real(n_tra_MODELO_vec .* cos_theta_t_MODELO_vec)) ./ (real(n_inc_MODELO_vec * cos_i_fijo));
            
            T_perp_MODELO_vs_wvl = factor_T_MODELO_vec .* abs(t_perp_MODELO_vs_wvl).^2; 
            T_para_MODELO_vs_wvl = factor_T_MODELO_vec .* abs(t_para_MODELO_vs_wvl).^2; 
            
            % T Experimental
            factor_T_USER_vec = (real(n_tra_USER_vec .* cos_theta_t_USER_vec)) ./ (real(n_inc_USER_vec * cos_i_fijo)); % Vector [N_exp, 1]
            
            T_perp_USER_vs_wvl = factor_T_USER_vec .* abs(t_perp_USER_vs_wvl).^2; 
            T_para_USER_vs_wvl = factor_T_USER_vec .* abs(t_para_USER_vs_wvl).^2; 

            % Limpieza de NaNs
            T_perp_MODELO_vs_wvl(isnan(T_perp_MODELO_vs_wvl) | isinf(T_perp_MODELO_vs_wvl)) = 0;
            T_para_MODELO_vs_wvl(isnan(T_para_MODELO_vs_wvl) | isinf(T_para_MODELO_vs_wvl)) = 0;
            T_perp_USER_vs_wvl(isnan(T_perp_USER_vs_wvl) | isinf(T_perp_USER_vs_wvl)) = 0;
            T_para_USER_vs_wvl(isnan(T_para_USER_vs_wvl) | isinf(T_para_USER_vs_wvl)) = 0;

            
            % Gráfica 5: Amplitud y Fase vs Longitud de Onda Barrido Espectral
            figure('Name', ['Barrido Espectral: Amplitud y Fase a ' num2str(theta_i_fijo_deg) ' grados - Comparación']); % (v11)
            
            subplot(2, 2, 1);
            plot(wvl_model_nm, abs(r_perp_MODELO_vs_wvl), 'g-', 'LineWidth', 2, 'DisplayName', '|r_s| - Modelo'); hold on;
            plot(wvl_model_nm, abs(r_para_MODELO_vs_wvl), 'r--', 'LineWidth', 2, 'DisplayName', '|r_p| - Modelo');
            plot(wvl_exp_nm, abs(r_perp_USER_vs_wvl), 'g-.', 'LineWidth', 1.5, 'DisplayName', '|r_s| - Exp.');
            plot(wvl_exp_nm, abs(r_para_USER_vs_wvl), 'r:', 'LineWidth', 1.5, 'DisplayName', '|r_p| - Exp.');
            title('Amplitud de Reflexión'); xlabel(xlabel_text_wvl); ylabel('Amplitud |r|');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);

            subplot(2, 2, 2);
            plot(wvl_model_nm, abs(t_perp_MODELO_vs_wvl), 'g-', 'LineWidth', 2, 'DisplayName', '|t_s| - Modelo'); hold on;
            plot(wvl_model_nm, abs(t_para_MODELO_vs_wvl), 'r--', 'LineWidth', 2, 'DisplayName', '|t_p| - Modelo');
            plot(wvl_exp_nm, abs(t_perp_USER_vs_wvl), 'g-.', 'LineWidth', 1.5, 'DisplayName', '|t_s| - Exp.');
            plot(wvl_exp_nm, abs(t_para_USER_vs_wvl), 'r:', 'LineWidth', 1.5, 'DisplayName', '|t_p| - Exp.');
            title('Amplitud de Transmisión'); xlabel(xlabel_text_wvl); ylabel('Amplitud |t|');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);

            subplot(2, 2, 3);
            plot(wvl_model_nm, rad2deg(angle(r_perp_MODELO_vs_wvl)), 'g-', 'LineWidth', 2, 'DisplayName', 'Fase(r_s) - Modelo'); hold on;
            plot(wvl_model_nm, rad2deg(angle(r_para_MODELO_vs_wvl)), 'r--', 'LineWidth', 2, 'DisplayName', 'Fase(r_p) - Modelo');
            plot(wvl_exp_nm, rad2deg(angle(r_perp_USER_vs_wvl)), 'g-.', 'LineWidth', 1.5, 'DisplayName', 'Fase(r_s) - Exp.');
            plot(wvl_exp_nm, rad2deg(angle(r_para_USER_vs_wvl)), 'r:', 'LineWidth', 1.5, 'DisplayName', 'Fase(r_p) - Exp.');
            title('Fase de Reflexión'); xlabel(xlabel_text_wvl); ylabel('Fase [grados]');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]); ylim([-180 180]); yticks(-180:90:180);

            subplot(2, 2, 4);
            plot(wvl_model_nm, rad2deg(angle(t_perp_MODELO_vs_wvl)), 'g-', 'LineWidth', 2, 'DisplayName', 'Fase(t_s) - Modelo'); hold on;
            plot(wvl_model_nm, rad2deg(angle(t_para_MODELO_vs_wvl)), 'r--', 'LineWidth', 2, 'DisplayName', 'Fase(t_p) - Modelo');
            plot(wvl_exp_nm, rad2deg(angle(t_perp_USER_vs_wvl)), 'g-.', 'LineWidth', 1.5, 'DisplayName', 'Fase(t_s) - Exp.');
            plot(wvl_exp_nm, rad2deg(angle(t_para_USER_vs_wvl)), 'r:', 'LineWidth', 1.5, 'DisplayName', 'Fase(t_p) - Exp.');
            title('Fase de Transmisión'); xlabel(xlabel_text_wvl); ylabel('Fase [grados]');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);
            ylim([-180 180]); yticks(-180:90:180);
            
            % --- Gráfica 6: Energía (R, T) vs Longitud de Onda (Ángulo Fijo) ---
            figure('Name', ['Barrido Espectral: Energía (R, T) a ' num2str(theta_i_fijo_deg) ' grados - Comparación']); % (v11)
            
            subplot(2, 2, 1);
            plot(wvl_model_nm, R_perp_MODELO_vs_wvl, 'b-', 'LineWidth', 2, 'DisplayName', 'R_s - Modelo'); hold on;
            plot(wvl_exp_nm, R_perp_USER_vs_wvl, 'b:', 'LineWidth', 1.5, 'DisplayName', 'R_s - Exp.');
            title('Reflectancia (R_s)');
            xlabel(xlabel_text_wvl); ylabel('Reflectancia R');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);
            data_Rs_wvl = [R_perp_MODELO_vs_wvl(:); R_perp_USER_vs_wvl(:)];
            setAxisLimits(data_Rs_wvl);

            subplot(2, 2, 2);
            plot(wvl_model_nm, T_perp_MODELO_vs_wvl, 'g-', 'LineWidth', 2, 'DisplayName', 'T_s - Modelo'); hold on;
            plot(wvl_exp_nm, T_perp_USER_vs_wvl, 'g:', 'LineWidth', 1.5, 'DisplayName', 'T_s - Exp.');
            title('Transmitancia (T_s)');
            xlabel(xlabel_text_wvl); ylabel('Transmitancia T');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);
            data_Ts_wvl = [T_perp_MODELO_vs_wvl(:); T_perp_USER_vs_wvl(:)];
            setAxisLimits(data_Ts_wvl);
            
            subplot(2, 2, 3);
            plot(wvl_model_nm, R_para_MODELO_vs_wvl, 'r-', 'LineWidth', 2, 'DisplayName', 'R_p - Modelo'); hold on;
            plot(wvl_exp_nm, R_para_USER_vs_wvl, 'r:', 'LineWidth', 1.5, 'DisplayName', 'R_p - Exp.');
            title('Reflectancia (R_p)');
            xlabel(xlabel_text_wvl); ylabel('Reflectancia R');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);
            data_Rp_wvl = [R_para_MODELO_vs_wvl(:); R_para_USER_vs_wvl(:)];
            setAxisLimits(data_Rp_wvl);

            subplot(2, 2, 4);
            plot(wvl_model_nm, T_para_MODELO_vs_wvl, 'm-', 'LineWidth', 2, 'DisplayName', 'T_p - Modelo'); hold on;
            plot(wvl_exp_nm, T_para_USER_vs_wvl, 'm:', 'LineWidth', 1.5, 'DisplayName', 'T_p - Exp.');
            title('Transmitancia (T_p)');
            xlabel(xlabel_text_wvl); ylabel('Transmitancia T');
            legend('show', 'Location', 'best'); grid on; xlim([wvl_min*1e9, wvl_max*1e9]);
            data_Tp_wvl = [T_para_MODELO_vs_wvl(:); T_para_USER_vs_wvl(:)];
            setAxisLimits(data_Tp_wvl);          

            % Fin Cálculos: Sacar Mensaje de Calculos Finalizados Correctamente
            set(handles.fig, 'Pointer', 'arrow'); % Restaurar cursor
            disp('Cálculo y gráficas completados exitosamente.');

        catch ME
            % Manejo de errores
            set(handles.fig, 'Pointer', 'arrow'); % Restaurar cursor
            errordlg(['Se produjo un error durante el cálculo: ' ME.message], 'Error de Cálculo');
            disp(['Error: ' ME.message]);
            for i = 1:length(ME.stack)
                disp(ME.stack(i));
            end
        end
    end % fin de runCalculation

    % Función auxiliar para ajustar ejes de manera adecuada
    function setAxisLimits(data_vector)
        min_val = min(data_vector, [], 'omitnan');
        max_val = max(data_vector, [], 'omitnan');
        padding = (max_val - min_val) * 0.1; 
        if padding == 0, padding = 0.05; end
        final_min = max(0, min_val - padding);
        final_max = min(1, max_val + padding);
        if final_min == final_max
            final_min = max(0, final_min - 0.05);
            final_max = min(1, final_max + 0.05);
        end
        ylim([final_min, final_max]);
    end

end % fin de DrudeFresnelGUI (función principal)