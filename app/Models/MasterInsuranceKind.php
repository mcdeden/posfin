<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class MasterInsuranceKind extends Model
{
    protected $table='master_insurance_kinds';
    public $incrementing = false;

    protected $fillable = [
        'id', 'name'
    ];
}
