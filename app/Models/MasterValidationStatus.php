<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterValidationStatus extends Model
{
    protected $table='master_validation_status';
    public $incrementing = true;

    protected $fillable = [
        'id', 'name'
    ];
}
